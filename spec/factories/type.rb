FactoryGirl.define do
  factory :type do
    sequence(:type_id, 30) { |n| n }
    sequence(:name) { |n| "Type#{n}" }
    group_id 18
    market_group_id 18
    published true
  end
end

