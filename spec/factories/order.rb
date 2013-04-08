FactoryGirl.define do
  factory :buy_order, class: Order do
    issued { 1.day.ago }
    sequence(:order_id)
    type_id 34
    region_id 10000002
    station_id 60003466
    price 6
    min_vol 1
    vol_enter 10
    vol_remain 10
    range 1
    duration 30
    bid true
    reported_ts { 1.hour.ago }
    gen_name 'FactoryGirl'
  end

  factory :sell_order, class: Order do
    issued { 1.day.ago }
    sequence(:order_id) { |n| 10000 + n.to_i}
    type_id 34
    region_id 10000002
    station_id 60003466
    price 6
    min_vol 1
    vol_enter 10
    vol_remain 10
    duration 30
    bid false
    reported_ts { 1.hour.ago }
    gen_name 'FactoryGirl'
  end
end

