class Order < ActiveRecord::Base
  scope :expired,    lambda { where("expires <= ?", Time.now) }
  scope :active,     lambda { where("expires > ?", Time.now) }
  scope :recent,     lambda { where("expires > ? and reported_ts >= ?", Time.now, 4.days.ago) }
  scope :old_report, lambda { where("reported_ts <= ?", 1.week.ago) }
  scope :last_hour,  lambda { where("reported_ts >= ?", 1.hour.ago) }
  scope :last_12h,   lambda { where("reported_ts >= ?", 12.hours.ago) }
  scope :last_day,   lambda { where("reported_ts >= ?", 1.day.ago) }
  scope :last_week,  lambda { where("reported_ts >= ?", 1.week.ago) }

  scope :valid, where(:outlier => false)
  scope :outliers, where(:outlier => true)

  scope :buy, where("bid = true")
  scope :sell, where("bid = false")

  scope :for_type, ->(id) { where(:type_id => id) }
  scope :for_region, ->(id) { where(:region_id => id) }

  scope :high_sec, joins(:solar_system).where("security >= 0.5")

  belongs_to :type
  belongs_to :station
  belongs_to :solar_system
  belongs_to :region

  has_many :logs, :class_name => 'OrderLog', :dependent => :destroy

  validates_presence_of :reported_ts, :issued, :gen_name
  validates_numericality_of :vol_enter, :order_id, :type_id, :station_id, :greater_than => 0
  validates_numericality_of :price, :greater_than => 0.25

  validate :check_duration
  validate :check_changes
  validate :timestamps
  validate :volumes

  delegate :name, :to => :type, :prefix => true, :allow_nil => true
  delegate :name, :to => :station, :prefix => true, :allow_nil => true
  delegate :name, :to => :region, :prefix => true, :allow_nil => true
  delegate :security, :to => :solar_system

  delegate :solar_system_id, :to => :station
  delegate :solar_system_name, :to => :station

  before_save :round_price
  before_save :set_expiration
  before_save :log_changes

  after_save :do_notify

  def self.notifiers
    @notifiers ||= []
  end

  def self.add_notifier(notifier)
    notifiers << notifier

    true
  end

  def self.clear_notifiers
    @notifiers = []
  end

  def self.recent(hours = 24, limit = 300)
    self.where("issued >= ?", hours.hours.ago)
        .limit(limit)
        .order("issued desc")
  end

  def round_price
    return unless price_changed?

    self.price = self.price.round(2)
  end

  def set_expiration
    self.expires = issued + duration.days if issued && duration
  end

  def expired?
    expires <= Time.now
  end

  def timestamps
    if reported_ts.nil?
      errors.add(:reported_ts, "Must be present")
    elsif issued.nil?
      errors.add(:issued, "Must be present")
    end
    return if errors.count > 0

#    if reported_ts > 30.minutes.from_now
#      errors.add(:reported_ts, "Reported in the future")
#    end

    if issued > 30.minutes.from_now
      errors.add(:issued, "Issued in the future")
    end

    if issued - reported_ts > 1.hour
      errors.add(:issued, "Issued after reported")
    end
  end

  def volumes
    if vol_remain.nil?
      errors.add(:vol_remain, "Must be present")
    elsif vol_enter.nil?
      errors.add(:vol_enter, "Must be present")
    end
    return if errors.count > 0

    if vol_remain > vol_enter
      errors.add(:vol_remain, "Should not be greater than volume entered")
    end
  end

  def check_duration
    if !duration.is_a?(Fixnum)
      errors.add(:duration, "must be an integer")
    elsif duration.between?(91, 364)
      errors.add(:duration, "cannot be between 90 and 365 days")
    elsif duration > 365
      errors.add(:duration, "cannot be over 365 days")
    end
  end

  def check_changes
    return if new_record?

    if vol_remain_changed?
      errors.add(:vol_remain, "Cannot increase from last seen") if vol_remain_was < vol_remain
    end

    if reported_ts_changed?
      errors.add(:reported_ts, "Cannot be prior to last seen") if reported_ts_was > reported_ts
    end

    if issued_changed?
      errors.add(:issued, "Cannot be prior to last seen") if issued_was > issued
    end
  end

  def price_vol_changed?
    (['price', 'vol_remain'] & self.changes.keys).present?
  end

  def log_changes
    return if new_record? || !price_vol_changed?

    OrderLog.log_order(self)

    true
  end

  def do_notify
    return unless self.class.notifiers.present?

    self.class.notifiers.each { |c| c.(self) }
  end

  def self.hubs
    hubs = Region.hub_region_ids

    Order.where(region_id: hubs)
  end

  def self.save_if_new(update)
    reported = parse_ts(update[:reported_ts])
    return unless reported && update[:order_id]

    o = Order.find_or_initialize_by_order_id(update[:order_id].to_i)

    if o.new_record? || (reported > o.reported_ts)
      o.update_attributes(update, :without_protection => true)
    else
      o = nil
    end

    o
  end

  def self.update_outliers(type = nil)
    types = type ? [Type.find(type)] : Type.on_market

    count = 0
    types.each do |type|
      Region.all.each do |region|
        orders = self.active.where(type_id: type.type_id, region_id: region.region_id)

        prices = orders.pluck(:price)
        next unless prices.length >= 8

        fences = prices.get_outer_fences
        next unless fences

        count += Order.flag_outliers(type.id, region.id, fences)
      end
    end

    count
  end

  def order_type
    bid ? :buy : :sell
  end

  def last_logs(count = 12)
    logs.order("reported_ts desc").limit(count)
  end


  private

  def self.parse_ts(ts)
    if ts.is_a?(String)
      Time.parse(ts).utc
    elsif ts.respond_to?(:to_time)
      ts.to_time
    else
      nil
    end
  end

  def self.flag_outliers(type_id, region_id, fences)
    orders = Order.where(:type_id => type_id, :region_id => region_id)

    count = 0
    ActiveRecord::Base.transaction do
      orders.outliers
            .where("price >= ? or price <= ?", fences[0], fences[1])
            .update_all(:outlier => false)

      count = orders.where(:outlier => false)
                    .where("price < ? or price > ?", fences[0], fences[1])
                    .update_all(:outlier => true)
    end

    count
  end

  def to_s
    "#{type_name} / #{station_name} / #{price}"
  end
end
