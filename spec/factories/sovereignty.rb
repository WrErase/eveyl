FactoryGirl.define do
  factory :sovereignty do
    sequence(:solar_system_id, 30000001)
    sequence(:alliance_id)
    sequence(:corporation_id)
    sequence(:faction_id)

    data_time { 5.minutes.ago }
  end
end
