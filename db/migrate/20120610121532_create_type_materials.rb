class CreateTypeMaterials < ActiveRecord::Migration
  def up
    create_table :type_materials, {:id => false} do |t|
      t.integer :type_id
      t.integer :material_type_id
      t.integer :quantity
    end
    execute "alter table type_materials add primary key (type_id, material_type_id)"

    add_index :type_materials, :type_id
  end

  def down
    drop_table :type_materials
  end
end
