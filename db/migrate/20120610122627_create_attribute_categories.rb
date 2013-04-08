class CreateAttributeCategories < ActiveRecord::Migration
  def up
    create_table :attribute_categories, :primary_key => :category_id do |t|
      t.integer :category_id
      t.string :name, :limit => 50
      t.string :description, :limit => 200
    end
  end

  def down
    drop_table :attribute_categories
  end
end
