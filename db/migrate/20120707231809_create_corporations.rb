class CreateCorporations < ActiveRecord::Migration
  def up
    create_table :corporations, :primary_key => :corporation_id do |t|
      t.string :name
      t.string :ticker, :limit => 5

      t.string :description, :limit => 4000
      t.boolean :npc, :default => false

      t.string :url

      t.integer :ceo_id
      t.string :ceo_name

      t.integer :member_count
      t.integer :member_limit

      t.integer :shares, :limit => 8

      t.float :tax_rate

      t.integer :graphic_id

      t.integer :station_id

      t.integer :alliance_id

      t.datetime :cached_until

      t.datetime :updated_at
    end

    add_index :corporations, :name
    add_index :corporations, :ticker
    add_index :corporations, :alliance_id
    add_index :corporations, :station_id
  end

  def down
    drop_table :corporations
  end
end
