class CreateUserProfiles < ActiveRecord::Migration
  def change
    create_table :user_profiles do |t|
      t.integer :user_id
      t.integer :default_region, default: '10000002'
      t.string :default_stat, default: 'median'
      t.string :timezone, default: 'UTC'
    end

    add_index :user_profiles, :user_id
  end
end
