FactoryGirl.define do
  factory :market_group do
    sequence(:market_group_id) { |n| n }
    sequence(:name) { |n| "Group#{n}" }
    description "Market Group Descr"
    sequence(:icon_id) { |n| n }
    has_types false
  end
end
