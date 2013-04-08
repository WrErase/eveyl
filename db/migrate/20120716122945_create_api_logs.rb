class CreateApiLogs < ActiveRecord::Migration
  def up
    create_table :api_logs do |t|
      t.string :resource_name
      t.integer :resource_id
      t.integer :key_id
      t.datetime :ts
      t.string :status
      t.datetime :cached_until
    end
  end

  def down
    drop_table :api_logs
  end
end
