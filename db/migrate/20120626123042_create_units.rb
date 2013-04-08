class CreateUnits < ActiveRecord::Migration
  def up
    create_table :units, :primary_key => :unit_id do |t|
      t.string  :name, :limit => 100
      t.string  :display_name, :limit => 50
      t.string  :description, :limit => 1000
    end
  end

  def down
    drop_table :units
  end
end
