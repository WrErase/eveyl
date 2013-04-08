class TypeMaterial < ActiveRecord::Base
  self.primary_keys = :type_id, :material_type_id

  belongs_to :type, :primary_key => :type_id, :foreign_key => :material_type_id

  delegate :name, :to => :type, :prefix => true

  validates :material_type_id, :presence => true, :numericality => true
end
