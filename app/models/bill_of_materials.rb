class BillOfMaterials
  attr_reader :bp, :last_required

  attr_accessor :me, :pe

  def initialize(options = {})
    @bp = options[:bp]
    @me = options[:me] || 0
    @pe = options[:pe] || 5
  end

  def me=(me)
    @me = me
    @last_required = nil
  end

  def pe=(pe)
    @pe = pe
    @last_required = nil
  end

  def base_materials
    if bp.respond_to?(:blueprint_type) && bp.blueprint_type.present?
      retval = bp.blueprint_type.materials
    else
      retval = bp.materials
    end
    retval.includes(:type, {:type => :category})
  end

  Material = Struct.new(:name, :type_id, :category, :base, :needed, :wasted)

  def material_multiplier
    pe_multi = (1.25 - 0.05 * pe)
    if me < 0
      retval = (1 + 0.1 - (me / 10.0)) * pe_multi
    else
      retval = (1 + 0.1 / (me + 1.0)) * pe_multi
    end

    retval
  end

  def build_base_materials
    return @base_materials if @base_materials

    @base_materials = base_materials.inject([]) do |ary, m|
      mat_id = m.material_type_id

      ary << Material.new(m.type_name, mat_id, m.type.category_name,
                          m.quantity, 0, 0)
    end
  end

  def calculate_needed(mat_list = [])
    mat_list.each do |m|
      next if m.base.nil? || m.base == 0

      multi = material_multiplier

      m.needed = (m.base * multi).round.to_i
      m.wasted = m.needed - m.base
    end
  end

  def add_additional_materials(mat_list = [])
    bp.mfg_requirements.each do |m|
      mat_id = m.required_type_id

      item = mat_list.detect { |v| v.type_id == mat_id }
      if item
        item.needed += (m.quantity * m.damage_per_job).round.to_i
        item.base += m.quantity
      else
        mat_list << Material.new(m.required_type_name,
                                 mat_id, m.required_type.category_name,
                                 m.quantity, m.quantity, 0)
      end
    end

    mat_list
  end

  def subtract_recycled(mat_list)
    bp.mfg_requirements.each do |mfg_req|
      next unless mfg_req.recycle

      mfg_req.required_type.materials.each do |rm_mat|
        item = mat_list.detect { |v| v.type_id == rm_mat.material_type_id }
        item.base -= rm_mat.quantity if item
      end
    end
  end

  def required
    return last_required if last_required

    mat_list = build_base_materials
    subtract_recycled(mat_list)
    calculate_needed(mat_list)
    add_additional_materials(mat_list)

    @last_required = mat_list.delete_if { |mat| mat.needed <= 0 }
  end

  def by_name(name)
    required.select { |m| m.name == name }
  end

  def by_category(category)
    required.select { |m| m.category == category }
  end

  def materials
    required.select { |m| m.category != 'Skill' }
            .sort { |b,a| a.needed <=> b.needed }
  end

  def skills
    required.select { |m| m.category == 'Skill' }
            .sort { |b,a| a.needed <=> b.needed }
  end
end
