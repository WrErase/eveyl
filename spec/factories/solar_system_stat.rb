FactoryGirl.define do
  factory :solar_system_stat do
    sequence(:id) { |i| i }
    solar_system_id 30000001
    ship_kills 1
    pod_kills 1
    faction_kills 1
    ship_jumps 1
    ts { Time.now }
  end
end

