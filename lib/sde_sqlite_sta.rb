# NPC Stations
# http://wiki.eve-id.net/StaStations_(CCP_DB)
class StaStations < ActiveRecord::Base
  self.establish_connection  Rails.application.config.database_configuration['eve_sde_sqlite']

  self.table_name = 'staStations'
  self.primary_key = :stationID
end

# Types of stations
# http://wiki.eve-id.net/StaStationTypes_(CCP_DB)
class StaStationTypes < ActiveRecord::Base
  self.establish_connection  Rails.application.config.database_configuration['eve_sde_sqlite']

  self.table_name = 'staStationTypes'
  self.primary_key = :stationTypeID
end
