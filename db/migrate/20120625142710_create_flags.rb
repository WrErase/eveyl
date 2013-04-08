class CreateFlags < ActiveRecord::Migration
  def up
    create_table :flags, :primary_key => :flag_id do |t|
      t.string :name, :limit => 200
      t.string :text, :limit => 100
    end
  end

  def down
    drop_table :flags
  end
end
