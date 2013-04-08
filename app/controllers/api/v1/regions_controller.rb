class Api::V1::RegionsController < Api::ApiController
  before_filter :parse_params

  def index
    regions = Region
    regions = regions.by_name(params[:q]) if params[:q]

    regions = regions.order("region_id asc")

    @pc = PagedCollection.new(regions, @page, @rpp,
                              api_regions_path)

    render 'index'
  end

  def show
    @region = Region.includes(:solar_systems).find(@region_id)

    render "show"
  end

  def names
    @names = Region.names(params[:q])

    render "names"
  end

  protected

  def parse_params
    if params[:id]
      return head :bad_request if params[:id] !~ /^\d{8}$/

      @region_id = params[:id].to_i
    end
  end
end
