object @order

extends "api/v1/orders/base"

attributes :gen_name, :gen_ver

child :last_logs => :logs do
  attributes :price, :vol_remain, :reported_ts, :gen_name, :gen_version
end

cache [:orders, params[:order_id]], expires_in: 10.minutes
