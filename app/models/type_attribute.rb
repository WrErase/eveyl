class TypeAttribute < ActiveRecord::Base
  self.primary_keys = :type_id, :attribute_id

  belongs_to :type

  belongs_to :attribute_type, :primary_key => :attribute_id, :foreign_key => :attribute_id

  delegate :name, :to => :attribute_type
  delegate :description, :to => :attribute_type
  delegate :default_value, :to => :attribute_type
  delegate :published, :to => :attribute_type
  delegate :display_name, :to => :attribute_type
  delegate :stackable, :to => :attribute_type
  delegate :unit_id, :to => :attribute_type
  delegate :category_id, :to => :attribute_type

  delegate :unit_name, :to => :attribute_type
  delegate :unit_display_name, :to => :attribute_type
  delegate :unit_description, :to => :attribute_type

  delegate :icon_file, :to => :attribute_type
  delegate :category_description, :to => :attribute_type

  validates :type_id, :presence => true, :numericality => true
  validates :attribute_id, :presence => true, :numericality => true

  def self.value_for_name(type_id, name)
    ta = TypeAttribute.select([:value_int, :value_float])
                      .where(:type_id => type_id)
                      .joins(:attribute_type)
                      .where(:attribute_types => {:name => name})
                      .first
    return nil unless ta

    ta.value_int || ta.value_float
  end
end
