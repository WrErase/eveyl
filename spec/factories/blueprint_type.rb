FactoryGirl.define do
  factory :blueprint_type do
    sequence(:type_id, 30) { |n| n }
    product_type_id 123
    production_time 40_000
    tech_level 1
    research_productivity_time 240000
    research_material_time 160000
    research_copy_time 400000
    research_tech_time 600000
    productivity_modifier 8000
    material_modifier 5
    waste_factor 10
    max_production_limit 10
  end
end
