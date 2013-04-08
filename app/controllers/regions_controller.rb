class RegionsController < ApplicationController
  respond_to :html

  def index
    @regions = Region.normal.order("name asc")

    respond_with @regions
  end

  def show
    @region = Region.find(params[:id])
    systems = @region.solar_systems.order("name asc")
    @solar_systems = SolarSystemDecorator.decorate_collection(systems)

    respond_with @region
  end
end
