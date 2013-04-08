# SDE - Factions
# http://wiki.eve-id.net/ChrFactions_(CCP_DB)
class ChrFactions < ActiveRecord::Base
  self.establish_connection  Rails.application.config.database_configuration['eve_sde_sqlite']

  self.table_name = 'chrFactions'
  self.primary_key = :factionID
end

