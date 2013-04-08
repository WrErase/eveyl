FactoryGirl.define do
  factory :character do
    sequence(:name) { |i| "John#{i}" }
  end
end
