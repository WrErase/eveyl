class CreateFactions < ActiveRecord::Migration
  def up
    create_table :factions, :primary_key => :faction_id do |t|
      t.integer :faction_id
      t.string :name, limit: 100
      t.string :description, limit: 1000
      t.integer :solar_system_id
      t.integer :corporation_id
      t.integer :station_count
      t.integer :station_system_count
      t.integer :militia_corporation_id
      t.integer :icon_id
    end

    add_index :factions, :name, :unique => true
    add_index :factions, :solar_system_id
    add_index :factions, :corporation_id
    add_index :factions, :militia_corporation_id
  end

  def down
    drop_table :factions
  end
end
