class Type < ActiveRecord::Base
  scope :published, where(published: true)
  scope :on_market, where("published = true AND market_group_id IS NOT NULL")

  scope :with_days_stats,
    includes(:order_stats).where("order_stats.ts >= ?", 1.day.ago).order("order_stats.ts desc")

  belongs_to :group, :foreign_key => :group_id, :primary_key => :group_id

  has_many :orders
  has_one :category, :through => :group

  belongs_to :market_group, :foreign_key => :market_group_id, :primary_key => :market_group_id

  has_one :meta_type, :foreign_key => :type_id
  has_one :meta_group, :through => :meta_type

  # Blueprint information for types that are blueprints
  has_one :blueprint_type, :class_name => 'BlueprintType'

  # Product information for types that are blueprints
  has_one :product, :source => :product, :through => :blueprint_type

  # Blueprint information for types that are not blueprints
  has_one :type_blueprint, :class_name => "BlueprintType", :primary_key => :type_id, :foreign_key => :product_type_id

  # Blueprint information for types that not blueprints
  has_one :blueprint, :source => :type, :through => :type_blueprint

  has_many :materials, :class_name => 'TypeMaterial'

  has_many :type_attributes
  has_many :attribute_types, :through => :type_attributes

  has_many :types, :through => :materials

  has_many :type_requirements

  has_many :order_histories
  has_many :order_stats
  has_many :type_values

  delegate :name, :to => :meta_group, :prefix => true, :allow_nil => true
  delegate :name, :to => :group, :prefix => true, :allow_nil => true
  delegate :name, :to => :category, :prefix => true, :allow_nil => true
  delegate :name, :to => :market_group, :prefix => true, :allow_nil => true
  delegate :name, :to => :blueprint, :prefix => true, :allow_nil => true
  delegate :name, :to => :product, :prefix => true, :allow_nil => true

  delegate :id, :to => :product, :prefix => true, :allow_nil => true
  delegate :type_id, :to => :blueprint, :prefix => true, :allow_nil => true

  delegate :mfg_requirements, :to => :blueprint_type

  # Blueprints
  delegate :tech_level, :to => :blueprint_type, :allow_nil => true
  delegate :research_productivity_time, :to => :blueprint_type, :allow_nil => true
  delegate :research_material_time, :to => :blueprint_type, :allow_nil => true
  delegate :research_copy_time, :to => :blueprint_type, :allow_nil => true
  delegate :research_tech_time, :to => :blueprint_type, :allow_nil => true
  delegate :productivity_modifier, :to => :blueprint_type, :allow_nil => true
  delegate :production_time, :to => :blueprint_type, :allow_nil => true
  delegate :material_modifier, :to => :blueprint_type, :allow_nil => true
  delegate :waste_factor, :to => :blueprint_type, :allow_nil => true
  delegate :max_production_limit, :to => :blueprint_type, :allow_nil => true

  def self.on_market_ids
    self.on_market.pluck(:type_id)
  end

  def self.find_by_name(q)
    where("name ilike ?", "%#{q}%")
  end

  def self.names(market = true, query_str = nil)
    query = published.select("type_id, name")
    query = query.on_market if market

    if query_str
      query = query.where("name ilike ?", "%#{query_str}%")
      names = query.order("name asc")
    else
      names = query.order("type_id asc")
    end

    names
  end

  def is_mineral?
    market_group_name == 'Minerals'
  end

  def is_skill?
    group_name == 'Skill'
  end

  def has_materials?
    materials.present?
  end

  def find_blueprint_type
    return @bp_type if @bp_type

    if self.is_blueprint?
      @bp_type = self.blueprint_type
    else
      @bp_type = self.blueprint.blueprint_type
    end

    @bp_type
  end

  def me_levels
    bp = find_blueprint_type
    bp.me_levels
  end

  def bill_of_materials(me = 0, character = nil)
    bp = find_blueprint_type
    bp.bill_of_materials(me, character)
  end

  def product_materials
    return unless product.present?

    product.materials
  end

  def is_blueprint?
    ! (name =~ /Blueprint$/).nil?
  end

  def has_blueprint?
    blueprint.present?
  end

  def latest_stats_for_region(region_id = nil)
    OrderStat.latest_stat(self.id, region_id)
  end

  def product_type
    product_id = BlueprintType.where(type_id: self.type_id).first.product_type_id
    Type.find(product_id)
  end

  def attribute_value(name)
    TypeAttribute.value_for_name(self.type_id, name)
  end

  def last_type_value(user = nil)
    if user.try(:user_profile)
      @type_value ||=
        TypeValue.find_by_region_stat(type_id,
                                      user.user_profile.default_region,
                                      user.user_profile.default_stat)
    end

    @type_value ||= TypeValue.find_by_region_stat(type_id)
  end

  def mkt_value(user = nil)
    value = last_type_value(user).try(:value)
    return unless value

    value.round(2)
  end

  def mat_value(user = nil)
    value = last_type_value(user).try(:mat_value)
    return unless value

    value.round(2)
  end

  def mat_perc(user = nil)
    mat = mat_value(user)
    mkt = mkt_value(user)

    return unless mat && mkt.to_f > 0

    (mat / mkt * 100).round(1)
  end

  def value_ts(user = nil)
    last_type_value(user).try(:ts)
  end

  def find_attribute_by_name(name)
    type_attributes
      .joins(:attribute_type)
      .where("attribute_types.name" => name).first
  end
end
