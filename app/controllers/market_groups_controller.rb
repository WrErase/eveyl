class MarketGroupsController < ApplicationController
  respond_to :html, :json

  def index
    @groups = MarketGroup.top_level
  end

  def show
    @group = MarketGroup.find(params[:id])

    return 404 unless @group

    respond_with @group
  end
end
