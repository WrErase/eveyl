class CreateStationTypes < ActiveRecord::Migration
  def up
    create_table :station_types, :primary_key => :station_type_id do |t|
      t.integer :dock_entry_x
      t.integer :dock_entry_y
      t.integer :dock_entry_z
      t.integer :dock_orientation_x
      t.integer :dock_orientation_y
      t.integer :dock_orientation_z
      t.integer :operation_id
      t.integer :office_slots
      t.integer :reprocessing_efficiency
      t.boolean :conquerable
    end
  end

  def down
    drop_table :station_types
  end
end
