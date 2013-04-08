FactoryGirl.define do
  factory :api_key do
    sequence(:key_id) { |i| i }
    user_id 1
    vcode 'a' * 64
  end
end
