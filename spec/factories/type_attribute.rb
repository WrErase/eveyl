FactoryGirl.define do
  factory :type_attribute do
    sequence(:attribute_id) { |n| n }
    sequence(:type_id) { |n| n }
    sequence(:value_int) { |n| n }
    value_float nil
  end
end

