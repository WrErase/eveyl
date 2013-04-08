class StationsController < ApplicationController
  respond_to :html

  before_filter :find_solar_system, only: [:index]

  def index
    @stations = Station.where(solar_system_id: params[:solar_system_id])
                      .order("name asc").decorate

    respond_with @stations
  end

  protected

  def find_solar_system
    begin
      @solar_system = SolarSystem.find(params[:solar_system_id])
    rescue ActiveRecord::RecordNotFound
      redirect_to :root, notice: "Unknown Solar System" unless @solar_system
      false
    end
  end
end
