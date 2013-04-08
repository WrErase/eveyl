FactoryGirl.define do
  factory :attribute_type do
    sequence(:attribute_id) { |n| n }
    sequence(:name) { |n| "AT#{n}" }
    sequence(:display_name) { |n| "AT#{n}" }
    description "Descr"
    published true
    stackable true
    high_is_good true
    sequence(:category_id) { |n| n }
  end
end

