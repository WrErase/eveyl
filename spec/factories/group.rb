FactoryGirl.define do
  factory :group do
    sequence(:group_id, 1) { |n| n }
    sequence(:category_id, 1) { |n| n }
    name 'GroupName'
    description 'descr'
    icon_id 1
  end
end
