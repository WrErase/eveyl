class TypesController < ApplicationController
  respond_to :html

  def index
  end

  def show
    @type = Type.includes(:group, :category, :market_group)
                .find(params[:id], :include => {:types => :materials})
                .decorate

    respond_with @type
  end
end
