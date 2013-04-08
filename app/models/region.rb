class Region < ActiveRecord::Base
  scope :has_hub, where(:has_hub => true)
  scope :has_high_sec,  joins(:solar_systems).where("solar_systems.security >= 0.5").group("regions.region_id")

  has_many :constellations
  has_many :solar_systems
  has_many :stations

  has_many :order_histories
  has_many :order_stats

  validates_presence_of :name
  validates :region_id, :presence => true, :numericality => true

  def self.get_regions(region_ids = nil)
    if region_ids.present?
      Region.find(region_ids)
    else
      Region.all
    end
  end

  def self.by_name(q)
    Region.where("name ilike ?", "%#{q}%")
  end

  def self.names(q = nil)
    if q.nil?
      Region.select([:name, :region_id]).order("name asc")
    else
      Region.select([:name, :region_id]).where("name ilike ?", "%#{q}%").order("name asc")
    end
  end

  def self.select_map
    self.has_hub.order("name").inject({}) do |m, r|
      m[r.name] = r.id
      m
    end
  end

  def self.normal
    where("name not like ?", "%-%")
  end

  def self.hub_region_ids
    Region.has_hub.pluck(:region_id)
  end

  def self.with_high_sec_ids
    has_high_sec.map(&:region_id)
  end

  def self.has_high_sec?(region_id)
    with_high_sec_ids.include?(region_id)
  end

  def self.order_histories_for_hubs(type_id)
    data = {}
    self.has_hub.each do |region|
      @order_history = region.order_histories_for_type(type_id)

      key = region.name.gsub(/ /, '').underscore

      data[key] = []
      @order_history.each do |oh|
        avg = oh.outlier? ? nil : oh.avg
        data[key] << [oh.ts.to_i * 1000, avg]
      end
    end

    data
  end

  def self.flag_security
    self.all.each do |r|
      if r.solar_systems.pluck(:security).uniq.detect { |i| i >= 0.5 }.nil?
        # TODO - Field for this?
      end
    end
  end

  def order_histories_for_type(type_id)
    self.order_histories
            .where(type_id: type_id)
            .last_year
            .order("ts asc")
  end

  def dotlan_url
    "http://evemaps.dotlan.net/map/" + self.name.gsub(' ', '_')
  end
end
