class AttributeType < ActiveRecord::Base
  belongs_to :unit, :primary_key => :unit_id, :foreign_key => :unit_id

  delegate :name, :to => :unit, :prefix => true, :allow_nil => true
  delegate :display_name, :to => :unit, :prefix => true, :allow_nil => true
  delegate :description, :to => :unit, :prefix => true, :allow_nil => true
end
