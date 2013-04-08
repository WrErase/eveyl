class CreateEveCentralImports < ActiveRecord::Migration
  def change
    create_table :eve_central_imports do |t|
      t.string :filename
      t.datetime :start
      t.datetime :stop
      t.integer :rows
      t.string :status
      t.string :error
    end

    add_index :eve_central_imports, :filename
    add_index :eve_central_imports, :start
    add_index :eve_central_imports, :stop
    add_index :eve_central_imports, :status
  end
end
