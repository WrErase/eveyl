class Api::V1::OrderHistoriesController < Api::ApiController
  before_filter :parse_params

  def index
    render :index
  end

  def show
    @histories = build_histories(@type_id, @region_id, @days)

    render :show
  end

  def search
    @histories = build_histories(@type_id, @region_id, @days)

    render :search
  end

  protected

  # TODO - Extract this
  def build_histories(type_id, region_id, days)
    order_query = OrderHistory.type_query(type_id, region_id, days)

    histories = OpenStruct.new(type_id: type_id, regions: [])

    # TODO - Handle single region selection better
    if region_id
      regions = [Region.find(region_id)]
    else
      regions = Region.has_hub.select("region_id, name").all
    end

    regions.each do |r|
      region = OpenStruct.new(region_id: r.region_id, name: r.name)

      region.order_histories = order_query.where(region_id: r.id)

      histories.regions << region unless region.order_histories.blank?
    end

    histories
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

    @days = (params[:days] || 365).to_i
    @days = 365 if @days > 365
  end
end
