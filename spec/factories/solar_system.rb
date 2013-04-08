FactoryGirl.define do
  factory :solar_system do
    sequence(:solar_system_id, 30000001)
    sequence(:name) { |n| "Station#{n}" }
    sequence(:region_id, 10000001)
    sequence(:constellation_id, 20000001)
    security 0.85
    security_class "B"
    border true
    fringe false
    corridor false
    hub true
    international true
    regional true
  end
end

