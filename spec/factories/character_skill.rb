FactoryGirl.define do
  factory :character_skill do
    sequence(:character_id) { |i| i }
    sequence(:type_id) { |i| i }
    level 1
    skill_points 100
  end
end
