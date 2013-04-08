class AssetsSearch
  def initialize(options = {})
    @ids    = options[:character_ids]
    @search = options[:query]
    @order  = options[:order] || 'types.name asc'
  end

  def search_is_type?
    return false unless @search

    !!(@search =~ /^\d{2,}$/)
  end

  def search_is_material?
    return false unless @search

    !!(@search =~ /Material/i)
  end

  def build_query
    raise ArgumentError unless @ids.present?

    assets = CharacterAsset.assets_for_characters(@ids)

    if @search
      if search_is_type?
        assets = type_id_query(assets)
      elsif search_is_material?
        # TODO - Match materials
      else
        assets = types_name_query(assets)
      end
    end

    assets.order(@order)
  end

  private

  def type_id_query(query)
    query.where("character_assets.type_id = ?", @search.to_i)
  end

  def types_name_query(query)
    query.where("types.name ilike ?", "%#{@search}%")
  end
end
