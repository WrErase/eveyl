FactoryGirl.define do
  factory :user_profile do
    sequence(:user_id) { |i| i }
    default_region 10000002
    default_stat 'median'
    timezone 'UTC'
  end
end
