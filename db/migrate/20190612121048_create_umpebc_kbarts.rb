class CreateUmpebcKbarts < ActiveRecord::Migration[5.2]
  def change
    create_table :umpebc_kbarts do |t|
      t.string :name
      t.integer :year
      t.date :updated

      t.timestamps
    end
    add_index :umpebc_kbarts, :name, unique: true
  end
end
