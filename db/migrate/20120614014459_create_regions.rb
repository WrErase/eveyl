class CreateRegions < ActiveRecord::Migration
  def up
    create_table :regions, :primary_key => :region_id do |t|
      t.string :name, :limit => 100
      t.integer :faction_id

      t.boolean :has_hub, :default => false
    end

    add_index :regions, :name
    add_index :regions, :faction_id
  end

  def down
    drop_table :regions
  end
end
