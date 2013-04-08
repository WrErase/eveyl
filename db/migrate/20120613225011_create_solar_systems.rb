class CreateSolarSystems < ActiveRecord::Migration
  def up
    create_table :solar_systems, :primary_key => :solar_system_id do |t|
      t.string  :name, :limit => 100

      t.integer :region_id
      t.integer :constellation_id

      t.integer :faction_id

      t.float   :security
      t.string  :security_class

      t.boolean :border
      t.boolean :fringe
      t.boolean :corridor
      t.boolean :hub

      t.boolean :international
      t.boolean :regional
      t.boolean :constellational
    end

    add_index :solar_systems, :name
    add_index :solar_systems, :region_id
    add_index :solar_systems, :constellation_id
    add_index :solar_systems, :faction_id
  end

  def down
    drop_table :solar_systems
  end
end
