# NPC Corporations
# http://wiki.eve-id.net/CrpNPCCorporations_(CCP_DB)
class CrpNPCCorporations < ActiveRecord::Base
  self.establish_connection  Rails.application.config.database_configuration['eve_sde_sqlite']

  self.table_name = 'crpNPCCorporations'
  self.primary_key = :corporationID
end
