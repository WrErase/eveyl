# Inventory Tables

# Names of space objects, corporations, people etc
# Replaces eveNames
class InvName < ActiveRecord::Base
  self.establish_connection  Rails.application.config.database_configuration['eve_sde_sqlite']

  self.table_name = 'invNames'
  self.primary_key = :itemID
end


# Inventory Categories
# http://wiki.eve-id.net/InvCategories_(CCP_DB)
class InvCategory < ActiveRecord::Base
  self.establish_connection  Rails.application.config.database_configuration['eve_sde_sqlite']

  self.table_name = 'invCategories'
  self.primary_key = :categoryID

  has_many :inv_groups, :foreign_key => :categoryID
end


# Inventory Groups
# http://wiki.eve-id.net/InvGroups_(CCP_DB)
class InvGroup < ActiveRecord::Base
  self.establish_connection  Rails.application.config.database_configuration['eve_sde_sqlite']

  self.table_name = 'invGroups'
  self.primary_key = :groupID

  has_many :inv_types, :foreign_key => :typeID
  belongs_to :inv_category, :foreign_key => :categoryID, :primary_key => :categoryID
end


# Inventory Market Groups
# http://wiki.eve-id.net/InvMarketGroups_(CCP_DB)
class InvMarketGroup < ActiveRecord::Base
  self.establish_connection  Rails.application.config.database_configuration['eve_sde_sqlite']

  self.table_name = 'invMarketGroups'
  self.primary_key = :marketGroupID

  has_many :inv_types, :foreign_key => :typeID
end


# Inventory Meta Types
# Relation between different variants of item (i.e. Tech-I, Faction, Tech-II)
# Not "meta-levels" of items used for calculate invention success
# http://wiki.eve-id.net/InvMetaTypes_(CCP_DB)
class InvMetaType < ActiveRecord::Base
  self.establish_connection  Rails.application.config.database_configuration['eve_sde_sqlite']

  self.table_name = 'invMetaTypes'

  belongs_to :inv_type, :foreign_key => :typeID
  has_one :inv_meta_group, :foreign_key => :metaGroupID, :primary_key => :metaGroupID

  delegate :metaGroupName, :to => :inv_meta_group
end


# Inventory Meta Groups
# http://wiki.eve-id.net/InvMetaGroups_(CCP_DB)
class InvMetaGroup < ActiveRecord::Base
  self.establish_connection  Rails.application.config.database_configuration['eve_sde_sqlite']

  self.table_name = 'invMetaGroups'
  self.primary_key = :metaGroupID

  belongs_to :inv_meta_type, :foreign_key => :metaGroupID
end


# Inventory Types
# Contains all in-game items
# http://wiki.eve-id.net/InvTypes_(CCP_DB)
class InvType < ActiveRecord::Base
  self.establish_connection  Rails.application.config.database_configuration['eve_sde_sqlite']

  self.table_name = 'invTypes'
  self.primary_key = :typeID

  has_one :inv_meta_type, :foreign_key => :typeID
  has_many :inv_type_material, :foreign_key => :typeID

  has_many :dgm_type_attributes, :foreign_key => :typeID

  belongs_to :inv_group, :foreign_key => :groupID, :primary_key => :groupID
  belongs_to :inv_market_group, :foreign_key => :marketGroupID, :primary_key => :marketGroupID

  # Associations
  delegate :inv_category, :to => :inv_group, :allow_nil => true

  # Fields
  delegate :metaGroupName, :to => :inv_meta_type, :allow_nil => true
  delegate :groupName, :to => :inv_group, :allow_nil => true
  delegate :categoryName, :to => :inv_category, :allow_nil => true
  delegate :marketGroupName, :to => :inv_market_group, :allow_nil => true
end


# Inventory Flags
# Used to identify the location and/or status of an item within an office,
#   station, ship, module or other container for the API calls
# http://wiki.eve-id.net/InvFlags_(CCP_DB)
class InvFlag < ActiveRecord::Base
  self.establish_connection  Rails.application.config.database_configuration['eve_sde_sqlite']

  self.table_name = 'invFlags'
  self.primary_key = :flagID
end


# Inventory Materials
# Material composition of items. This is used in reprocessing,
#   as well as in manufacturing
# http://wiki.eve-id.net/InvTypeMaterials_(CCP_DB)
class InvTypeMaterial < ActiveRecord::Base
  self.establish_connection  Rails.application.config.database_configuration['eve_sde_sqlite']

  self.table_name = 'invTypeMaterials'

  belongs_to :material_type, :class_name => "InvType", :primary_key => :typeID, :foreign_key => :materialTypeID
end


# Inventory Blueprints
# Information about blueprints
# Units/run can be retrieved from the invTypes table
# http://wiki.eve-id.net/InvBlueprintTypes_(CCP_DB)
class InvBlueprintType < ActiveRecord::Base
  self.establish_connection  Rails.application.config.database_configuration['eve_sde_sqlite']

  self.table_name = 'invBlueprintTypes'

  belongs_to :inv_type, :primary_key => :typeID, :foreign_key => :blueprintTypeID
  belongs_to :product_type, :class_name => "InvType", :primary_key => :typeID, :foreign_key => :productTypeID
end

