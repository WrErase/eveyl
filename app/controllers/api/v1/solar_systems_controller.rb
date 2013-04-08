class Api::V1::SolarSystemsController < Api::ApiController
  before_filter :parse_params

  def index
    systems = SolarSystem
    systems = systems.where(region_id: params[:region_id]) if params[:region_id]
    systems = systems.by_name(params[:q]) if params[:q]

    systems = systems.order("solar_system_id asc")

    @pc = PagedCollection.new(systems, @page, @rpp,
                              api_solar_systems_path)

    render :index
  end

  def show
    @solar_system = SolarSystem.includes(:solar_system_stats, :stations).find(@system_id)

    render :show
  end

  def names
    @names = SolarSystem.names(params[:q])

    render :names
  end

  protected

  def parse_params
    if params[:id]
      return head :bad_request if params[:id] !~ /^\d{8}$/

      @system_id = params[:id].to_i
    end
  end
end
