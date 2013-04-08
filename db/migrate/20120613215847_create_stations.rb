class CreateStations < ActiveRecord::Migration
  def up
    create_table :stations, :primary_key => :station_id do |t|
      t.string :name, :limit => 100

      t.integer :solar_system_id
      t.integer :constellation_id
      t.integer :region_id

      t.integer :corporation_id
      t.integer :station_type_id

      t.float :reprocess_eff
      t.float :reprocess_take

      t.datetime :created_at
      t.datetime :updated_at
    end

    add_index :stations, :region_id
    add_index :stations, :name

    add_index :stations, :station_type_id
    add_index :stations, :corporation_id
    add_index :stations, :constellation_id
    add_index :stations, :solar_system_id
  end

  def down
    drop_table :stations
  end
end
