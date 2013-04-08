# Extra items required by blueprints to build or research
# http://wiki.eve-id.net/RamTypeRequirements_(CCP_DB)
class RamTypeRequirements < ActiveRecord::Base
  self.establish_connection  Rails.application.config.database_configuration['eve_sde_sqlite']

  self.table_name = 'ramTypeRequirements'
  self.primary_key = [:typeID, :activityID, :requiredTypeID]
end

# Research and Manufacturing Activities
# http://wiki.eve-id.net/RamActivities_(CCP_DB)
class RamActivities < ActiveRecord::Base
  self.establish_connection  Rails.application.config.database_configuration['eve_sde_sqlite']

  self.table_name = 'ramActivities'
  self.primary_key = :activityID
end
