FactoryGirl.define do
  factory :character_asset do
    sequence(:item_id)
    sequence(:character_id)
    sequence(:type_id)

    sequence(:solar_system_id)
    sequence(:station_id)

    quantity 1
    singleton false

    parent_id nil

  end
end
