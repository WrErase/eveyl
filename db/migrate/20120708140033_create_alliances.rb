class CreateAlliances < ActiveRecord::Migration
  def up
    create_table :alliances, :primary_key => :alliance_id do |t|
      t.string :name
      t.string :short_name
      t.integer :executor_corp_id
      t.integer :member_count
      t.datetime :start_date

      t.datetime :created_at
      t.datetime :updated_at
    end

    add_index :alliances, :name
    add_index :alliances, :short_name
  end

  def down
    drop_table :alliances
  end
end
