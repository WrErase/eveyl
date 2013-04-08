class CreateAccounts < ActiveRecord::Migration
  def up
    create_table :accounts do |t|
      t.integer :key_id

      t.datetime :paid_until
      t.datetime :create_date
      t.integer  :logon_count
      t.integer  :logon_minutes

      t.integer :user_id

      t.datetime :cached_until

      t.datetime :created_at
      t.datetime :updated_at
    end

    add_index :accounts, :key_id
    add_index :accounts, :user_id
  end

  def down
    drop_table :accounts
  end
end
