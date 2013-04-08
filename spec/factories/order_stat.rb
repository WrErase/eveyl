FactoryGirl.define do
  factory :order_stat do
    sequence(:id)
    type_id 34
    region_id 10000002
    median 4
    max_buy 4
    min_sell 5
    mid_buy_sell 4.5
    sell_vol 100000
    buy_vol 200000
    sim_buy 5.25
    sim_sell 4.25
    ts { Time.now }
  end
end
