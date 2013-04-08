class BlueprintType < ActiveRecord::Base
  belongs_to :type
  belongs_to :product, :class_name => "Type", :primary_key => :type_id, :foreign_key => :product_type_id

  validates :product_type_id, :presence => true, :numericality => true
  validates :tech_level, :presence => true, :numericality => true
  validates :max_production_limit, :presence => true, :numericality => true

  validates :research_productivity_time, :presence => true, :numericality => true
  validates :research_material_time, :presence => true, :numericality => true
  validates :research_copy_time, :presence => true, :numericality => true
  validates :research_tech_time, :presence => true, :numericality => true

  validates :productivity_modifier, :presence => true, :numericality => true
  validates :material_modifier, :presence => true, :numericality => true
  validates :waste_factor, :presence => true, :numericality => true

  has_many :type_requirements, :primary_key => :type_id, :foreign_key => :type_id

  belongs_to :product, :class_name => 'Type', :primary_key => :type_id, :foreign_key => :product_type_id
  has_many :materials, :through => :product

  delegate :name, :to => :type, :prefix => true
  delegate :name, :to => :product, :prefix => true

  Material = Struct.new(:name, :type_id, :needed, :wasted)

  def me_levels
    #FIXME - Calculate per bp
    [0, 10, 50]
  end

  def bill_of_materials(me = 0, character = nil)
    if character
      BillOfMaterials.new(bp: self, me: me, pe: character.pe_level)
    else
      BillOfMaterials.new(bp: self, me: me)
    end
  end

  def mfg_requirements
    # FIXME - Can't make includes work,
    # query for each required_type, category
    type_requirements.joins(:activity)
                     .where("activities.name" => 'Manufacturing')
  end

  def invention_requirements
    type_requirements.joins(:activity)
                     .where("activities.name" => 'Invention')
  end
end
