class OrderStat < ActiveRecord::Base
  belongs_to :type
  belongs_to :region

  delegate :name, :to => :type, :prefix => true
  delegate :name, :to => :region, :prefix => true, :allow_nil => true

  validates :ts, :presence => true
  validates :type_id, :presence => true, :numericality => true
  validates :region_id, :numericality => true, :allow_nil => true

  PLEX_ID = 29668

  # Days to go back when pulling active orders
  TIME_BACK = 3.days


  def self.value_stats
    [:sim_buy, :sim_sell, :mid_buy_sell, :median, :weighted_avg]
  end

  def self.all_stats
    [:mid_buy_sell, :sim_buy, :sim_sell, :weighted_avg, :median, :buy_vol, :sell_vol]
  end

  def self.stat_types
    value_stats + [:sell_vol, :buy_vol]
  end

  # Simulate transaction of paying for percent of the orders
  # Assumes orders are ordered by price either ascending (buy) or descending (sell)
  def self.sim_xact(orders, percent = 0.05)
    total = to_xact = (0.05 * orders.sum(:vol_remain)).round(0)
    return if total < 1

    paid = 0
    orders.each do |o|
      next if o.expired?
      if o.vol_remain <= to_xact
        to_xact -= o.vol_remain
        paid += o.vol_remain * o.price
      else
        paid += to_xact * o.price
        break
      end
    end

    (paid.to_f / total).round(2)
  end

  def self.sim_buy(orders, percent = 0.05)
    orders = orders.sell.order('price asc')

    sim_xact(orders, percent)
  end

  def self.sim_sell(orders, percent = 0.05)
    orders = orders.buy.order('price desc')

    sim_xact(orders, percent)
  end


  def self.orders_for_region(type_id, region_id)
    query = Order.where(type_id: type_id, region_id: region_id)

    max = latest_reported(query)
    return [] unless max

    # Allows for stats to be build from older order data
    query.where("reported_ts >= ?", max - TIME_BACK)
         .where("expires >= ?", max)
  end

  def self.orders_for_hubs(type_id)
    Order.hubs.where(:type_id => type_id).active
  end

  def self.build_region_stats(region_id, type_id)
    orders = orders_for_region(type_id, region_id)

    build_stats(orders)
  end

  def self.build_hubs_stats(type_id)
    orders = Order.hubs.active.where(type_id: type_id)

    build_stats(orders)
  end

  def self.latest_reported(orders)
    orders.maximum(:reported_ts)
  end

  def self.build_stats(orders)
    price_data = price_data(orders)
    return if price_data.empty?

    stats = {}
    all_prices = []
    [:buy, :sell].each do |order_type|
      next if price_data[order_type].nil?
      prices = extract_prices(price_data[order_type])

      vol = filtered_vol(price_data[order_type])

      if order_type == :buy
        stats[:max_buy]  = prices.max
        stats[:buy_vol]  = vol
      else
        stats[:min_sell]  = prices.min
        stats[:sell_vol]  = vol
      end

      all_prices.concat(prices)
    end
    stats[:sim_buy]  = sim_buy(orders)
    stats[:sim_sell] = sim_sell(orders)
    stats[:median]   = all_prices.median.round(2) unless all_prices.empty?
    stats[:ts]       = latest_reported(orders)

    if stats[:max_buy] && stats[:min_sell]
      stats[:mid_buy_sell] = mid_buy_sell(stats)
    end

    stats
  end

  def self.build_type_stats(type = nil, region_ids = nil)
    regions = Region.get_regions(region_ids)

    stats = []
    build_types(type).each do |type|
      regions.each do |region|
        type_stats = build_region_stats(region.id, type.id)
        next unless type_stats

        type_stats[:type_id] = type.id
        type_stats[:region_id] = region.id

        stats << type_stats
      end

      hubs_stats = build_hubs_stats(type.id)
      if hubs_stats
        hubs_stats[:type_id] = type.id
        stats << hubs_stats
      end
    end

    stats
  end

  def self.last_too_recent?(type_id)
    last = self.last_stat(type_id)

    last && last < 6.hours.ago
  end

  def self.build_all(region_ids = nil)
    mkt_types.each do |type|
      next if last_too_recent?(type.id)

      # TODO - Batch this up? (types * regions storage)
      stats = self.build_type_stats(type.id, region_ids)
      save_stats(stats)
    end
  end

  def self.build_materials(region_ids = nil)
    MarketGroup.minerals.each do |type|
      stats = self.build_type_stats(type.id, region_ids)
      save_stats(stats)
    end
  end

  def self.last_stat(type_id)
    OrderStat.where(type_id: type_id).maximum(:ts)
  end

  protected

  def self.extract_prices(price_data)
    price_data.collect { |i| i[:price] }
  end

  def self.mid_buy_sell(stats)
    ((stats[:max_buy] + stats[:min_sell]) / 2.0).round(2)
  end

  def self.filter_outliers(price_data)
    outliers = price_data.collect { |i| i[:price] }.find_outliers
    return price_data unless outliers

    price_data.dup.delete_if { |p| outliers.include?(p[:price]) }
  end

  def self.filtered_vol(price_data)
    filtered = filter_outliers(price_data)

    filtered.inject(0) { |sum, d| sum += d[:vol] }
  end

  def self.build_types(type = nil)
    return type if type.is_a?(Type)

    if type.nil?
      types = mkt_types
    else
      types = [Type.find(type)]
    end
  end

  def self.price_data(orders)
    price_data = {}
    orders.each do |order|
      price_data[order.order_type] ||= []
      price_data[order.order_type] << {price: order.price, vol: order.vol_remain}
    end

    price_data
  end

  def self.save_stats(stats)
    ActiveRecord::Base.transaction do
      stats.each do |type_stat|
        a = create(type_stat, without_protection: true)
      end
    end
  end

  def self.all_regions
    @regions ||= Region.all
  end

  def self.mkt_types
    @types ||= Type.on_market.to_a
  end

  def self.select_map
    {"Median" => "median",
     "Mid Buy-Sell" => "mid_buy_sell",
     "Sim 5% Buy" => "sim_buy",
     "Sim 5% Sell" => "sim_sell",
     "Weighted Average" => "weighted_avg"}
  end

  def self.type_query(type_id, region_id, days, order = 'ts desc')
    order_query = OrderStat.where(type_id: type_id)
    order_query = order_query.where(region_id: region_id) if region_id
    order_query = order_query.where("ts >= ?", days.days.ago) if days
    order_query = order_query.order(order)
  end

  def self.for_minerals
    MarketGroup.minerals.includes(:order_stats).order("type_id asc")
  end

  def self.latest_stat(type_id, region_id)
    self.where(type_id: type_id, region_id: region_id)
        .order("ts desc")
        .limit(1)
        .first
  end

  def self.stat_recent?(stat)
    stat.present? && stat.ts > 2.weeks.ago
  end

  # TODO - Extract this to be cachable?
  def self.minerals_for_hubs
    stats = {}

    types = MarketGroup.minerals + Type.where(type_id: PLEX_ID)
    types.each do |type|
      Region.hub_region_ids.each do |region_id|
        stats[type.name] ||= {}

        stat = latest_stat(type.id, region_id)

        stats[type.name][region_id] = stat if stat_recent?(stat)
      end
    end

    stats
  end

  def self.region_stats(type_id, high_sec = false)
    if high_sec
      query = Region.has_high_sec
    else
      query = Region
    end

    stats = {}
    query.order("regions.name asc").each do |region|
      stat = latest_stat(type_id, region.id)
      if stat.present? && stat.ts > 1.month.ago
        stats[region.name] = stat
      end
    end

    stats
  end
end
