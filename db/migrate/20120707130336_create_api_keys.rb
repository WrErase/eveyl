class CreateApiKeys < ActiveRecord::Migration
  def up
    create_table :api_keys do |t|
      t.integer :key_id
      t.string :vcode

      t.integer :access_mask

      t.integer :user_id

      t.string :key_type
      t.datetime :expires

      t.datetime :cached_until

      t.datetime :created_at
      t.datetime :updated_at
    end

    add_index :api_keys, :key_id, :unique => true
    add_index :api_keys, :user_id
  end

  def down
    drop_table :api_keys
  end
end
