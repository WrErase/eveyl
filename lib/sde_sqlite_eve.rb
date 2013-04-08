# Measurement units used in game
# http://wiki.eve-id.net/EveUnits_(CCP_DB)
class EveUnit < ActiveRecord::Base
  self.establish_connection  Rails.application.config.database_configuration['eve_sde_sqlite']

  self.table_name = 'eveUnits'
  self.primary_key = :unitID
end

# Icons - id to file mappings
# http://wiki.eve-id.net/EveIcons_(CCP_DB)
class EveIcon < ActiveRecord::Base
  self.establish_connection  Rails.application.config.database_configuration['eve_sde_sqlite']

  self.table_name = 'eveIcons'
  self.primary_key = :iconID
end

