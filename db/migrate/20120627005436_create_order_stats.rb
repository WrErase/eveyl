class CreateOrderStats < ActiveRecord::Migration
  def up
    create_table :order_stats do |t|
      t.integer :type_id
      t.integer :region_id

      t.float :median

      t.float :max_buy
      t.float :min_sell
      t.float :mid_buy_sell
      t.float :weighted_avg

      t.integer :buy_vol, :limit => 8
      t.integer :sell_vol, :limit => 8

      t.float :sim_buy
      t.float :sim_sell

      t.datetime :ts
    end

    add_index :order_stats, :type_id
    add_index :order_stats, :region_id

    add_index :order_stats, [:type_id, :region_id, :ts]
  end

  def down
    drop_table :order_stats
  end
end
