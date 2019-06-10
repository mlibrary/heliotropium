class CreateLibPtgFolders < ActiveRecord::Migration[5.2]
  def change
    create_table :lib_ptg_folders do |t|
      t.string :name
      t.string :flavor
      t.integer :month
      t.date :update

      t.timestamps
    end
    add_index :lib_ptg_folders, :name, unique: true
  end
end
