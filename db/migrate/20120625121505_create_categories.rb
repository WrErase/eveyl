class CreateCategories < ActiveRecord::Migration
  def up
    create_table :categories, :primary_key => :category_id do |t|
      t.string :name, :limit => 100
      t.string :description, :limit => 3000
      t.integer :icon_id
      t.boolean :published
    end
  end

  def down
    drop_table :categories
  end
end
