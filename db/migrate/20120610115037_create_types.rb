class CreateTypes < ActiveRecord::Migration
  def up
    create_table :types, :primary_key => :type_id do |t|
      t.string  :name, :limit => 100
      t.integer :group_id
      t.string  :description, :limit => 3000
      t.column :mass, 'double precision'
      t.column :volume, 'double precision'
      t.column :capacity, 'double precision'
      t.integer :portion_size
      t.integer :race_id
      t.column :base_price, 'decimal(19,4)'
      t.boolean :published
      t.integer :market_group_id
      t.column :chance_of_duplicating, 'double precision'
      t.integer :icon_id

      t.integer :tech_level
      t.integer :meta_level
    end

    add_index :types, :group_id
    add_index :types, :market_group_id
  end

  def down
    drop_table :types
  end
end
