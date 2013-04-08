class OrderSearch
  DEFAULT_HOURS = 60_000

  def initialize(options = {})
    @bid       = options.fetch(:bid, false)
    @type_id   = options[:type_id]
    @region_id = options[:region_id]
    @hours     = options[:hours]
    @high_sec  = options[:high_sec] || false
    @query     = options[:query]
    @includes  = options[:includes]
    @order     = options[:order]
  end

  def hours_ago
    @hours.hours.ago
  end

  def load_params(params)
    extract_bid_param(params)
    extract_order_param(params)
    extract_region_param(params)
    extract_type_param(params)

    extract_sec_param(params)
    extract_hour_param(params)
  end

  def build_query
    raise InvalidQuery unless @query || @type_id

    query = @query || Order

    query = query.includes(@includes) if @includes

    query = query.where(type_id: @type_id) if @type_id
    query = query.active

    query = query.where(bid: @bid) unless @bid.nil?
    query = query.where(region_id: @region_id) if @region_id
    query = query.where("reported_ts >= ?", hours_ago) if @hours
    query = query.high_sec if @high_sec
    query = query.order(@order) if @order

    query
  end

  def extract_bid_param(params)
    if params[:bid].present?
      raise InvalidQuery unless params[:bid] =~ /^\d$/

      @bid = params[:bid] == '0' ? false : true
    end
  end

  def extract_order_param(params)
    if params[:order_id].present?
      raise InvalidQuery unless params[:order_id] =~ /^\d{2,16}$/

      @order_id = params[:order_id].to_i
    end
  end

  def extract_region_param(params)
    if params[:region_id].present?
      raise InvalidQuery unless params[:region_id] =~ /^\d{8}$/

      @region_id = params[:region_id].to_i
    end
  end

  def extract_type_param(params)
    if params[:type_id].present?
      raise InvalidQuery unless params[:type_id] =~ /^\d{2,8}$/

      @type_id = params[:type_id].to_i
    end
  end

  def extract_sec_param(params)
    @high_sec = params[:high_sec] == '1' ? true : false
  end

  def extract_hour_param(params)
    @hours = (params[:hours] || DEFAULT_HOURS).to_i
  end
  class InvalidQuery < Exception; end
end
