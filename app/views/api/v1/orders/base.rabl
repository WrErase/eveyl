attributes :order_id, :type_id, :region_id, :region_name, :solar_system_id, :station_id,
           :station_name, :price, :min_vol, :vol_remain, :vol_enter, :range, :duration,
           :issued, :outlier

node :expires do |o|
  o.expires.utc.strftime("%D %R")
end

node :reported_ts do |o|
  o.reported_ts.utc.strftime("%D %R")
end

attribute :order_type do |o|
  o.bid ? 'buy' : 'sell'
end
