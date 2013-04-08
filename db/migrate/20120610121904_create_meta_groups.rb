class CreateMetaGroups < ActiveRecord::Migration
  def up
    create_table :meta_groups, :primary_key => :meta_group_id do |t|
      t.integer :meta_group_id
      t.string :name, :limit => 100
      t.string  :description, :limit => 3000
      t.integer :icon_id
    end
  end

  def down
    drop_table :meta_groups
  end
end
