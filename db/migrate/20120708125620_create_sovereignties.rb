class CreateSovereignties < ActiveRecord::Migration
  def up
    create_table :sovereignties, :primary_key => :solar_system_id  do |t|
      t.integer :alliance_id
      t.integer :corporation_id
      t.integer :faction_id

      t.datetime :data_time
    end

    add_index :sovereignties, :alliance_id
    add_index :sovereignties, :corporation_id
    add_index :sovereignties, :faction_id
  end

  def down
    drop_table :sovereignties
  end
end
