class SolarSystemsController < ApplicationController
  respond_to :html

  before_filter :find_region, only: [:index]

  def index
    systems = SolarSystem.where(region_id: params[:region_id])
                         .order("name asc")
    @solar_systems = SolarSystemDecorator.decorate_collection(systems) #.first

    respond_with @solar_systems
  end

  def show
    @solar_system = SolarSystem.find(params[:id]).decorate

    respond_with @solar_system
  end

  protected

  def find_region
    begin
      @region = Region.find(params[:region_id])
    rescue ActiveRecord::RecordNotFound
      redirect_to :root, notice: "Unknown Region" unless @region
      false
    end
  end
end
