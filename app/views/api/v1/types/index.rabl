object @pc

child :collection => :types do
  extends "api/v1/types/base"

  node :links do |t|
    {'self' => {href: api_type_path(t)},
     'order_histories' => {href: api_type_order_histories_path(t)},
    }
  end
end

node :pagination do |s|
  s.to_hash
end
