object @pc

child :collection => :orders do
  extends "api/v1/orders/base"

  node :links do |o|
    {'self' => {href: api_order_path(o) }
    }
  end
end

node :pagination do |o|
  o.to_hash
end

cache [:orders, params[:bid], params[:type_id], params[:region_id],
                              params[:hours], params[:high_sec]], expires_in: 10.minutes
