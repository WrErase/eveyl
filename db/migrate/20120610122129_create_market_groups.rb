class CreateMarketGroups < ActiveRecord::Migration
  def up
    create_table :market_groups, :primary_key => :market_group_id do |t|
      t.integer :market_group_id
      t.integer :parent_group_id
      t.string :name, :limit => 100
      t.string :description, :limit => 3000
      t.integer :icon_id
      t.boolean :has_types
    end
  end

  def down
    drop_table :market_groups
  end
end
