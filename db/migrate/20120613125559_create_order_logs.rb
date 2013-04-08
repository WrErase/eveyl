class CreateOrderLogs < ActiveRecord::Migration
  def up
    create_table :order_logs do |t|
      t.integer :order_id, :limit => 8

      t.decimal :price

      t.integer :vol_remain

      t.timestamp :reported_ts

      t.string :gen_name
      t.string :gen_version
    end

    add_index :order_logs, [:order_id, :reported_ts], :unique => true
  end

  def down
    drop_table :order_logs
  end
end
