class CorporationsController < ApplicationController
  respond_to :html, :json

  def show
    @corporation = Corporation.find(params[:id]).decorate

    respond_with @corporation
  end
end
