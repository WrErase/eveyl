class CreateOrderHistories < ActiveRecord::Migration
  def up
    create_table :order_histories do |t|
      t.integer :type_id
      t.integer :region_id

      t.integer :orders
      t.integer :quantity, :limit => 8

      t.float :low
      t.float :high
      t.float :average

      t.datetime :ts

      t.string :gen_name
      t.string :gen_version

      t.boolean :outlier, :default => false
    end

    add_index :order_histories, [:type_id, :region_id, :ts], :unique => true
  end

  def down
    drop_table :order_histories
  end
end
