class CreateTypeValues < ActiveRecord::Migration
  def change
    create_table :type_values do |t|
      t.datetime :ts

      t.integer :type_id
      t.integer :region_id

      t.string :stat

      t.float :value
      t.float :mat_value
    end

    add_index :type_values, [:type_id, :region_id, :stat, :id]
  end
end
