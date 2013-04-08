class CreateAttributeTypes < ActiveRecord::Migration
  def up
    create_table :attribute_types, :primary_key => :attribute_id do |t|
      t.integer :attribute_id
      t.string :name, :limit => 100
      t.string :description, :limit => 1000
      t.integer :icon_id
      t.column :default_value, "double precision"
      t.boolean :published
      t.string :display_name, :limit => 100
      t.integer :unit_id
      t.boolean :stackable
      t.boolean :high_is_good
      t.integer :category_id
    end
  end

  def down
    drop_table :attribute_types
  end
end
