class CreateSolarSystemStats < ActiveRecord::Migration
  def up
    create_table :solar_system_stats do |t|
      t.integer :solar_system_id

      t.integer :ship_kills, default: 0
      t.integer :pod_kills, default: 0
      t.integer :faction_kills, default: 0
      t.integer :ship_jumps, default: 0

      t.datetime :ts
    end

    add_index :solar_system_stats, :solar_system_id
    add_index :solar_system_stats, [:ts, :solar_system_id], :unique => true
  end

  def down
    drop_table :solar_system_stats
  end
end
