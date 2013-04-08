class CreateTypeAttributes < ActiveRecord::Migration
 def up
    create_table :type_attributes, {:id => false} do |t|
      t.integer :type_id
      t.integer :attribute_id
      t.integer :value_int
      t.float :value_float
    end
    execute "alter table type_attributes add primary key (type_id, attribute_id)"

    add_index :attribute_types, :unit_id
    add_index :attribute_types, :category_id
    add_index :type_attributes, :type_id
  end

  def down
    drop_table :type_attributes
  end
end
