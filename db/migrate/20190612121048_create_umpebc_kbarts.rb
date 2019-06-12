class CreateUmpebcKbarts < ActiveRecord::Migration[5.2]
  def change
    create_table :umpebc_kbarts do |t|
      t.string :name, null: false
      t.integer :year, null: false, default: 1970
      t.date :updated, null: false, default: Time.new(1970, 1, 1)

      t.timestamps
    end
    add_index :umpebc_kbarts, :name, unique: true
  end
end
