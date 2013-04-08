class StatusesController < ApplicationController
  respond_to :html, :json

  def show
    @stats = Status.stats
  end
end
