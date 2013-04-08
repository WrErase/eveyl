class CreateOrders < ActiveRecord::Migration
  def up
    create_table :orders, :id => false do |t|
      t.integer :order_id, :limit => 8
      t.integer :type_id

      t.boolean :bid

      t.integer :region_id
      t.integer :solar_system_id
      t.integer :station_id

      t.decimal :price

      t.integer :min_vol
      t.integer :vol_remain
      t.integer :vol_enter
      t.integer :range

      t.integer :duration

      t.timestamp :issued
      t.timestamp :expires

      t.timestamp :reported_ts

      t.string :gen_name
      t.string :gen_version

      t.boolean :outlier, :default => false
    end
    execute "ALTER TABLE orders ADD PRIMARY KEY (order_id);"

#    add_index :orders, :type_id
#    add_index :orders, :region_id
    add_index :orders, :solar_system_id
#    add_index :orders, :station_id

#    add_index :orders, :price
#    add_index :orders, :expires
#    add_index :orders, :reported_ts, :order => "desc"

    # Order Search API
#    add_index :orders, [:price, :bid, :type_id, :expires, :reported_ts], name: 'index_orders_on_bid_and_type_and_expires_and_reported'

    add_index :orders, [:type_id, :expires, :reported_ts], name: 'index_orders_on_type_and_and_expires_and_reported'
    add_index :orders, [:type_id, :region_id, :expires, :reported_ts], name: 'index_orders_on_type_and_region_and_expires_and_reported'
  end

  def down
    drop_table :orders
  end
end
