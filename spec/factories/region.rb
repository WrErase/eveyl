FactoryGirl.define do
  factory :region do
    sequence(:region_id, 10000010) { |n| n }
    faction_id 500007
    sequence(:name) { |n| "Region#{n}" }
    has_hub false
  end

  factory :the_forge, class: Region do
    region_id 10000002
    faction_id 500001
    name 'The Forge'
    has_hub true
  end
end

