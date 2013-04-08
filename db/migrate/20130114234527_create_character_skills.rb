class CreateCharacterSkills < ActiveRecord::Migration
  def change
    create_table :character_skills do |t|
      t.integer :character_id
      t.integer :type_id
      t.integer :skill_points
      t.integer :level
      t.boolean :published, default: true
    end

    add_index :character_skills, :character_id
    add_index :character_skills, :type_id
  end
end
