class Station < ActiveRecord::Base
  scope :player, joins(:station_type).where("station_types.conquerable = true")
  scope :high_sec, joins(:solar_system).where("solar_systems.security >= 0.5")
  scope :low_sec, joins(:solar_system).where("solar_systems.security > 0 and solar_systems.security < 0.5")
  scope :null_sec, joins(:solar_system).where("solar_systems.security <= 0")

  belongs_to :solar_system
  belongs_to :constellation
  belongs_to :region

  belongs_to :station_type
  belongs_to :corporation

  delegate :name, :to => :corporation, :prefix => true, :allow_nil => true
  delegate :name, :to => :solar_system, :prefix => true
  delegate :name, :to => :constellation, :prefix => true
  delegate :name, :to => :region, :prefix => true

  delegate :conquerable, :to => :station_type

  delegate :security, :to => :solar_system

  def self.update_from_api(result)
    return unless result

    solar = SolarSystem.find_by_solar_system_id(result.solarSystemID)

    s = self.find_or_initialize_by_station_id(result.stationID)
    s.update_attributes({:name => result.stationName,
                         :station_type_id => result.stationTypeID,
                         :region_id => solar.region_id,
                         :constellation_id => solar.constellation_id,
                         :solar_system_id => result.solarSystemID,
                         :corporation_id => result.corporationID},
                         :without_protection => true)
  end

  def dotlan_url
    "http://evemaps.dotlan.net/station/" + name.gsub(' ', '_')
  end
end
