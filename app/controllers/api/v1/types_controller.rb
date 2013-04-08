class Api::V1::TypesController < Api::ApiController
  before_filter :parse_params

  def index
    query = @on_market ? Type.on_market : Type.published

    query = query.find_by_name(params[:q]) if params[:q]

    @pc = PagedCollection.new(query, @page, @rpp,
                              api_types_path)

    render :index
  end

  def show
    @type = Type.find(@type_id) if @type_id

    return head :not_found unless @type

    render "show"
  end

  def names
    return head :bad_request unless params[:q]

    @names = Type.names(@on_market, params[:q])

    render "names"
  end

  protected

  def parse_params
    if params[:q]
      return head :bad_request if params[:q] !~ /^[\w\s\-]{2,80}$/
    end

    if params[:id]
      return head :bad_request if params[:id] !~ /^\d{2,8}$/

      @type_id = params[:id].to_i
    end

    if params[:on_market]
      return head :bad_request if params[:on_market] !~ /^0|1$/

      @on_market = params[:on_market] == '0' ? false : true
    else
      @on_market = true
    end
  end

end
