class BlueprintTypes < ActiveRecord::Migration
  def up
    create_table :blueprint_types, :primary_key => :type_id do |t|
      t.integer :type_id
      t.integer :product_type_id
      t.integer :production_time
      t.integer :tech_level
      t.integer :research_productivity_time
      t.integer :research_material_time
      t.integer :research_copy_time
      t.integer :research_tech_time
      t.integer :productivity_modifier
      t.integer :material_modifier
      t.integer :waste_factor
      t.integer :max_production_limit
    end

    add_index :blueprint_types, :product_type_id
  end

  def down
    drop_table :blueprint_types
  end
end
