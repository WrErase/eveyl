class CreateActivities < ActiveRecord::Migration
  def change
    create_table :activities, primary_key: :activity_id do |t|
      t.integer :activity_id
      t.string :name
      t.integer :icon_no
      t.string :description
      t.boolean :published
    end
  end
end
