class OrderHistory < ActiveRecord::Base
  scope :valid, where("outlier != true")
  scope :last_year, where("ts >= ?", 1.year.ago)
  scope :last_day, where("ts >= ?", 1.day.ago)

  belongs_to :type
  belongs_to :region

  validates_numericality_of :type_id, :region_id, :quantity, :greater_than => 0
  validate :stats

  before_save :round_prices

  delegate :name, :to => :type, :prefix => true
  delegate :name, :to => :region, :prefix => true

  def self.exists?(type_id, region_id, ts)
    !!(self.where(type_id: type_id, region_id: region_id, ts: ts).first)
  end

  def self.reltuples
    sql = "select reltuples from pg_class where relname = 'order_histories'"

    ActiveRecord::Base.connection.select_all(sql).first['reltuples'].to_f.to_i
  end

  def round_prices
    self.low = self.low.round(2)
    self.high = self.high.round(2)
    self.average = self.average.round(2)
  end

  def stats
    if low > high
      errors.add(:low, "Cannot be greater than high")
    end

    if average > high
      errors.add(:average, "Cannot be greater than high")
    end

    if average < low
      errors.add(:average, "Cannot be less than low")
    end
  end

  def self.flag_outliers
    start = Time.mktime(1.year.ago.year, 1.year.ago.month)

    Type.on_market_ids.each do |type_id|
      0.upto(12) do |i|
        range_start, range_end = start + i.month, start + (1+i).month - 1
        histories = OrderHistory.where(:type_id => type_id, :ts => range_start..range_end)

        prices = histories.pluck(:average)

        next if prices.length < 6

        outliers = prices.find_outliers
        unless outliers.blank?
          # TODO - Fix this
          histories.where("average in (?)", outliers).update_all(outlier: true)
          histories.where("average not in (?)", outliers).update_all(outlier: false)
        end
      end
    end
  end

  def self.type_query(type_id, region_id, days, order = 'ts desc')
    order_query = OrderHistory.where(type_id: type_id)
    order_query = order_query.where(region_id: region_id) if region_id
    order_query = order_query.where("ts >= ?", days.days.ago) if days
    order_query = order_query.order(order)
  end

  def to_s
    "#{type_name} / #{region_name} / #{ts}"
  end

end
