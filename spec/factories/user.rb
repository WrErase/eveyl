FactoryGirl.define do
  factory :user do
    email 'john@sample.co'
    password 'abc123'
    admin false
  end
end
