FactoryGirl.define do
  factory :station do
    sequence(:station_id, 60000001)
    sequence(:name) { |n| "Station#{n}" }
    sequence(:solar_system_id, 30000001)
    sequence(:constellation_id, 30000001)
    sequence(:region_id, 10000001)
    sequence(:corporation_id, 90000001)
    station_type_id 1531
    reprocess_eff 0.5
    reprocess_take 0.05
    created_at { 3.days.ago }
    updated_at { 1.day.ago }
  end
end

