class TypeRequirement < ActiveRecord::Base
  validates :type_id, presence: true
  validates :activity_id, presence: true
  validates :required_type_id, presence: true

  belongs_to :type
  belongs_to :activity

  belongs_to :required_type, class_name: 'Type'
  belongs_to :blueprint_type, :foreign_key => :type_id

  delegate :name, :to => :required_type, :prefix => true
end
