class CreateSovereigntyHistories < ActiveRecord::Migration
  def up
    create_table :sovereignty_histories do |t|
      t.integer :solar_system_id
      t.integer :alliance_id
      t.integer :corporation_id
      t.integer :faction_id

      t.datetime :data_time
    end

    add_index :sovereignty_histories, :solar_system_id
    add_index :sovereignty_histories, :alliance_id
    add_index :sovereignty_histories, :corporation_id
    add_index :sovereignty_histories, :faction_id

    add_index :sovereignty_histories, [:solar_system_id, :data_time], :unique => true
  end

  def down
    drop_table :sovereignty_histories
  end
end
