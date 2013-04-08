class Api::V1::OrdersController < Api::ApiController
  before_filter :parse_params

  rescue_from OrderSearch::InvalidQuery, with: :invalid_query

  def index
    # TODO - Orders nested under a type
    if params[:type_id]
      query = build_query
      @orders = query.limit(@rpp).offset(@skip)

      render "search"
    else
      render :index
    end
  end

  def show
    @order = Order.find(params[:id]) if params[:id]

    return head :not_found unless @order

    render "show"
  end

  def search
    return head :bad_request unless params[:type_id]

    query = build_query

    if datatable_query?
      @orders = query.paginate(page: @page, per_page: @rpp)
      @total = query.count
      @orders = OrderDecorator.decorate_collection(@orders)
      columns = [:region_name, :station_name_with_security, :price,
                 :vol_remain,:expires, :reported_ts, :id]
      render :text => DataTable.search_to_table(@orders, @total, columns).to_json
    else
      @pc = PagedCollection.new(query, @page, @rpp, api_orders_path)
      render :search
    end
  end

  def recent
    @orders = Order.recent(24, 300)
  end

  protected

  def build_query
    search = OrderSearch.new(includes: [:region, :station, :solar_system],
                             order: @order)

    search.load_params(params)

    search.build_query
  end

  def parse_params
    if datatable_query?
      headings = ["regions.name", "stations.name", "price", "vol_remain",
                  "expires", "reported_ts"]
      @order = DataTable.table_to_order(params, headings)
    end

    params[:order_id] = params[:id] unless params[:order_id]
  end
end
