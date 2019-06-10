class CreateLibPtgFolders < ActiveRecord::Migration[5.2]
  def change
    create_table :lib_ptg_folders do |t|
      t.string :name, null: false
      t.string :flavor, null: false, default: "year"
      t.integer :month, null: false, default: 0
      t.date :touched, null: false, default: Time.new(1970, 1, 1)

      t.timestamps
    end
    add_index :lib_ptg_folders, :name, unique: true
  end
end
