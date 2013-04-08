class CreateMetaTypes < ActiveRecord::Migration
  def up
    create_table :meta_types, :primary_key => :type_id do |t|
      t.integer :type_id
      t.integer :parent_type_id
      t.integer :meta_group_id
    end

    add_index :meta_types, :meta_group_id
  end

  def down
    drop_table :meta_types
  end
end
