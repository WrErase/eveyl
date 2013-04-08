class OrdersController < ApplicationController
  respond_to :html

  def index
    render :index
  end

  def show
    begin
      @order = Order.includes(:type, :region, :station, :logs)
                    .find(params[:id])
    rescue ActiveRecord::RecordNotFound
      return redirect_to orders_path, notice: "Invalid ID"
    end

    @order_logs = @order.logs.order("reported_ts desc")

    respond_with @order
  end

  def search
    unless params[:type_id]
      return redirect_to orders_path, :notice => "Invalid Type ID"
    end

    @type = Type.find(params[:type_id]).decorate
    @region_id = params[:region_id]
    @high_sec = params[:hisec_only] == 'on' ? '1' : '0'

    @region_stats = OrderStat.region_stats(params[:type_id], true)

    respond_to do |format|
      format.html { render }
    end
  end

  def recent
    @orders = Order.recent(24, 300)
  end
end
