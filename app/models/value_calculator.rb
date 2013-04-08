class ValueCalculator
  attr_reader :stat_type, :region_id

  MIN_VALUE = 0.25

  def initialize(options = {})
    @stat_type  = options[:stat_type] || :mid_buy_sell
    @region_id  = options[:region_id] || 10000002

    @cache = OpenStruct.new(values: {}, mat_values: {})
  end

  def value(item)
    value_by_type_id(item.type_id)
  end

  def value_by_type_id(type_id)
    return @cache.values[type_id] if @cache.values[type_id]

    value = OrderStat.latest_stat(type_id, @region_id)
                     .try(@stat_type)
    raise NoStatForRegion, "#{type_id}, #{@region_id}" unless value

    @cache.values[type_id] = value if value.to_f > MIN_VALUE
  end

  def self.build_values(type_id = nil)
    type_ids = type_id.present? ? [type_id] : Type.on_market.pluck(:type_id)

    Region.pluck(:region_id).each do |region_id|
      OrderStat.value_stats.each do |stat|
        calc = self.new(stat_type: stat, region_id: region_id)

        type_ids.each { |type_id| build_values_with_calc(calc, type_id) }
      end
    end
  end

  def mat_value(item)
    if @cache.mat_values[item.type_id]
      return @cache.mat_values[item.type_id]
    end

    materials = get_materials(item)
    return unless materials.present?

    value = materials.inject(0) do |total, mat|
      type_value = value_by_type_id(mat.material_type_id)
      raise NoStatForRegion, "#{mat.material_type_id}, #{@region_id}" unless type_value

      total += type_value * mat.quantity
    end
    value = value.to_f / (item.portion_size || 1)

    @cache.mat_values[item.type_id] = value if value.to_f > MIN_VALUE
  end

  def mat_value_by_type_id(type_id)
    item = Type.find(type_id)

    mat_value(item)
  end

  private

  def self.build_values_with_calc(calc, type_id)
    begin
      value = calc.value_by_type_id(type_id)
      type_value = TypeValue.new(ts: Time.now, type_id: type_id,
                                 region_id: calc.region_id,
                                 stat: calc.stat_type, value: value)
      mat_value = calc.mat_value_by_type_id(type_id)
      type_value.mat_value = mat_value
    rescue ValueCalculator::NoStatForRegion => e
      Rails.logger.debug "No stat for region #{calc.region_id}: #{e.message}"
    ensure
      type_value.save if type_value
    end
  end

  def get_materials(item)
    if item.respond_to?(:materials)
      materials = item.materials
    else
      #FIXME - Why?
      materials = TypeMaterials.where(type_id: item.type_id)
    end
  end

  class NoStatForRegion < Exception; end
end
