class CreateConstellations < ActiveRecord::Migration
  def up
    create_table :constellations, :primary_key => :constellation_id do |t|
      t.string :name, :limit => 100
      t.integer :region_id
      t.integer :faction_id
    end

    add_index :constellations, :name
    add_index :constellations, :region_id
    add_index :constellations, :faction_id
  end

  def down
    drop_table :constellations
  end
end
