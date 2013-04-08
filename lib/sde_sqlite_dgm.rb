# Attribute Categories and their descriptions
# http://wiki.eve-id.net/DgmAttributeCategories_(CCP_DB)
class DgmAttributeCategory < ActiveRecord::Base
  self.establish_connection  Rails.application.config.database_configuration['eve_sde_sqlite']

  self.table_name = 'dgmAttributeCategories'
  self.primary_key = :categoryID
end


# Names and descriptions of attributes
# http://wiki.eve-id.net/DgmAttributeTypes_(CCP_DB)
class DgmAttributeType < ActiveRecord::Base
  self.establish_connection  Rails.application.config.database_configuration['eve_sde_sqlite']

  self.table_name = 'dgmAttributeTypes'
  self.primary_key = :attributeID

  belongs_to :eve_unit, :primary_key => :unitID, :foreign_key => :unitID
  belongs_to :eve_icon, :primary_key => :iconID, :foreign_key => :iconID

  belongs_to :dgm_attribute_category, :primary_key => :categoryID, :foreign_key => :categoryID

  delegate :categoryName, :to => :dgm_attribute_category, :allow_nil => true
  delegate :categoryDescription, :to => :dgm_attribute_category, :allow_nil => true

  delegate :unitName, :to => :eve_unit, :allow_nil => true
  delegate :displayName, :to => :eve_unit, :prefix => :unit, :allow_nil => true
  delegate :description, :to => :eve_unit, :prefix => :unit, :allow_nil => true

  delegate :iconFile, :to => :eve_icon, :allow_nil => true


  def unitDisplayName
    self.unit_displayName
  end

  def unitDescription
    self.unit_description
  end
end

# All attributes for items
# http://wiki.eve-id.net/DgmTypeAttributes_(CCP_DB)
class DgmTypeAttribute < ActiveRecord::Base
  self.establish_connection  Rails.application.config.database_configuration['eve_sde_sqlite']

  self.table_name = 'dgmTypeAttributes'

  belongs_to :inv_type
  belongs_to :dgm_attribute_type, :primary_key => :attributeID, :foreign_key => :attributeID

  delegate :attributeName, :to => :dgm_attribute_type
  delegate :description, :to => :dgm_attribute_type
  delegate :defaultValue, :to => :dgm_attribute_type
  delegate :published, :to => :dgm_attribute_type
  delegate :displayName, :to => :dgm_attribute_type
  delegate :stackable, :to => :dgm_attribute_type

  delegate :iconFile, :to => :dgm_attribute_type

  delegate :unitName, :to => :dgm_attribute_type, :allow_nil => true
  delegate :unitDisplayName, :to => :dgm_attribute_type, :allow_nil => true
  delegate :unitDescription, :to => :dgm_attribute_type, :allow_nil => true

  delegate :categoryName, :to => :dgm_attribute_type, :allow_nil => true
  delegate :categoryDescription, :to => :dgm_attribute_type, :allow_nil => true
end
