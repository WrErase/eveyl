class CreateGroups < ActiveRecord::Migration
  def up
    create_table :groups, :primary_key => :group_id do |t|
      t.integer :group_id
      t.integer :category_id
      t.string  :name, :limit => 100
      t.string  :description, :limit => 3000
      t.integer :icon_id
      t.boolean :use_base_price
      t.boolean :allow_manufacture
      t.boolean :allow_recycler
      t.boolean :anchored
      t.boolean :anchorable
      t.boolean :fittable_non_singleton
      t.boolean :published
    end

    add_index :groups, :category_id
  end

  def down
    drop_table :groups
  end
end
