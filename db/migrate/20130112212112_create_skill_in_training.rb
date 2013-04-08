class CreateSkillInTraining < ActiveRecord::Migration
  def change
    create_table :skill_in_training do |t|
      t.integer :character_id
      t.integer :type_id

      t.integer :start_sp
      t.integer :destination_sp
      t.integer :to_level

      t.datetime :start_time
      t.datetime :end_time

      t.datetime :reported_ts
    end

    add_index :skill_in_training, :character_id
  end
end
