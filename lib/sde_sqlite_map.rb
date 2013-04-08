# List of solar systems
# http://wiki.eve-id.net/MapSolarSystems_(CCP_DB)
class MapSolarSystem < ActiveRecord::Base
  self.establish_connection  Rails.application.config.database_configuration['eve_sde_sqlite']

  self.table_name = 'mapSolarSystems'
  self.primary_key = :solarSystemID
end


# List of regions
# http://wiki.eve-id.net/MapRegions_(CCP_DB)
class MapRegion < ActiveRecord::Base
  self.establish_connection  Rails.application.config.database_configuration['eve_sde_sqlite']

  self.table_name = 'mapRegions'
  self.primary_key = :regionID
end


# List of constellation
# http://wiki.eve-id.net/MapConstellations_(CCP_DB)
class MapConstellation < ActiveRecord::Base
  self.establish_connection  Rails.application.config.database_configuration['eve_sde_sqlite']

  self.table_name = 'mapConstellations'
  self.primary_key = :constellationID
end

# List of all solar systems jump connections
# http://wiki.eve-id.net/MapSolarSystemJumps_(CCP_DB)
class MapSolarSystemJumps < ActiveRecord::Base
  self.establish_connection  Rails.application.config.database_configuration['eve_sde_sqlite']

  self.table_name = 'mapSolarSystemJumps'
  self.primary_key = :fromRegionID
end


# List of all solar systems jump connections
# http://wiki.eve-id.net/MapRegionJumps_(CCP_DB)
class MapRegionJumps < ActiveRecord::Base
  self.establish_connection  Rails.application.config.database_configuration['eve_sde_sqlite']

  self.table_name = 'mapRegionJumps'
  self.primary_key = :fromRegionID
end

