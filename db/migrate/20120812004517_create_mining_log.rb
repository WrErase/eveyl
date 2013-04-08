class CreateMiningLog < ActiveRecord::Migration
  def up
    create_table :mining_log do |t|
      t.integer :character_id

      t.timestamp :start_ts
      t.timestamp :stop_ts

      t.string :name
      t.string :comments
    end
    add_index :mining_log, :character_id
  end

  def down
    drop_table :mining_log
  end
end
