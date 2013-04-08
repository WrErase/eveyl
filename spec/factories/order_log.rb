FactoryGirl.define do
  factory :order_log do
    price 10
    vol_remain 100
    reported_ts 1.hour.ago
    gen_name 'Gen'
    gen_version = '1.0'
  end
end
