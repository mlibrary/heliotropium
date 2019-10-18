class CreateUmpebcFiles < ActiveRecord::Migration[5.2]
  def change
    create_table :umpebc_files do |t|
      t.string :name, null: false, unique: true
      t.string :checksum

      t.timestamps
    end
  end
end
