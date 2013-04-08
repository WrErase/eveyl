class SolarSystem < ActiveRecord::Base
  belongs_to :region

  has_many :stations
  has_many :orders

  has_one :sovereignty

  has_one :faction, :through => :sovereignty
  has_one :alliance, :through => :sovereignty
  has_one :corporation, :through => :sovereignty

  belongs_to :constellation

  has_many :solar_system_stats

  delegate :name, :to => :region, :prefix => true
  delegate :name, :to => :constellation, :prefix => true
  delegate :name, :to => :faction, :prefix => true, :allow_nil => true
  delegate :name, :to => :alliance, :prefix => true, :allow_nil => true

  validates_presence_of :name

  validates :region_id, :presence => true, :numericality => true
  validates :constellation_id, :presence => true, :numericality => true
  validates :security, :presence => true, :numericality => true

  def self.ids
    self.pluck(:solar_system_id)
  end

  def self.by_name(q)
    where("name ilike ?", "%#{q}%")
  end

  def self.names(q = nil)
    if q.nil?
      select([:name, :solar_system_id]).order("name asc")
    else
      select([:name, :solar_system_id]).where("name ilike ?", "%#{q}%").order("name asc")
    end
  end

  def stats_48h
    solar_system_stats.last_48h
  end

  def stats_72h
    solar_system_stats.last_72h
  end

  def dotlan_url
    "http://evemaps.dotlan.net/system/" + name.gsub(' ', '_')
  end
end
