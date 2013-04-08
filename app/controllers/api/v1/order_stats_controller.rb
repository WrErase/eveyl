class Api::V1::OrderStatsController < Api::ApiController
  before_filter :parse_params

  def index
    render :index
  end

  def search
    @stats = build_stats(@type_id, @region_id, @days)

    render :search
  end

  protected

  def build_stats(type_id, region_id, days)
    order_query = OrderStat.type_query(type_id, region_id, days)

    stats = OpenStruct.new(type_id: type_id, regions: [])

    if region_id
      regions = [Region.find(region_id)]
    else
      regions = Region.has_hub.select("region_id, name").all
    end

    regions.each do |r|
      region = OpenStruct.new(region_id: r.region_id, name: r.name)
      region.order_stats = order_query.where(region_id: r.id)

      stats.regions << region unless region.order_stats.blank?
    end

    stats
  end

  def parse_params
    if params[:type_id]
      return head :bad_request if params[:type_id] !~ /^\d{2,8}$/

      @type_id = params[:type_id].to_i
    else
      return head :bad_request
    end

    if params[:region_id]
      return head :bad_request if params[:region_id] !~ /^\d{8}$/

      @region_id = params[:region_id].to_i
    end

    @days = (params[:days] || 30).to_i
    @days = 30 if @days > 30
  end
end
