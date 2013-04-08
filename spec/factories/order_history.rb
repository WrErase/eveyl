FactoryGirl.define do
  factory :order_history do
    sequence(:id)
    type_id 34
    region_id 10000003
    quantity 1
    low 1000.0
    high 5000.0
    average 3000.0
    outlier false
    ts { Time.now }
  end
end
