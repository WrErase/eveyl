class CreateTypeRequirements < ActiveRecord::Migration
  def change
    create_table :type_requirements, {id: false} do |t|
      t.integer :type_id
      t.integer :activity_id
      t.integer :required_type_id
      t.integer :quantity
      t.float :damage_per_job
      t.boolean :recycle
    end
    execute "alter table type_requirements add primary key (type_id, activity_id, required_type_id)"
  end
end
