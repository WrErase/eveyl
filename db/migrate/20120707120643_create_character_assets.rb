class CreateCharacterAssets < ActiveRecord::Migration
  def up
    create_table :character_assets, :id => false do |t|
      t.integer :character_id

      t.integer :item_id, :limit => 8

      t.integer :solar_system_id
      t.integer :station_id

      t.integer :type_id
      t.integer :quantity
      t.integer :flag
      t.boolean :singleton
      t.integer :raw_quantity

      t.integer :parent_id, :limit => 8

      t.datetime :created_at
      t.datetime :updated_at
    end
    execute "ALTER TABLE character_assets ADD PRIMARY KEY (item_id);"

    add_index :character_assets, :character_id
    add_index :character_assets, :parent_id
    add_index :character_assets, :solar_system_id
    add_index :character_assets, :station_id
    add_index :character_assets, :type_id
  end

  def down
    drop_table :character_assets
  end
end
