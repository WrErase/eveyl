class CreateCharacters < ActiveRecord::Migration
  def up
    create_table :characters, :primary_key => :character_id do |t|
      t.integer :key_id

      t.string :name
      t.datetime :dob
      t.string :race
      t.string :bloodline
      t.string :ancestry
      t.string :gender
      t.integer :corporation_id
      t.integer :alliance_id
      t.string :clone_name
      t.integer :clone_sp
      t.integer :balance, :limit => 8

      t.boolean :hidden, :default => false

      t.integer :intelligence
      t.integer :memory
      t.integer :charisma
      t.integer :perception
      t.integer :willpower

      t.datetime :cached_until

      t.datetime :created_at
      t.datetime :updated_at
    end

    add_index :characters, :corporation_id
    add_index :characters, :alliance_id
  end

  def down
    drop_table :characters
  end
end
