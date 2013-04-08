FactoryGirl.define do
  factory :type_value do
    ts Time.parse('2013-01-01')
    sequence(:type_id, 30) { |n| n }
    region_id 10000002
    stat :median
    value 100
    mat_value 90
  end
end

