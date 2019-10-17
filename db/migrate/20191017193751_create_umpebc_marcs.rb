class CreateUmpebcMarcs < ActiveRecord::Migration[5.2]
  def change
    create_table :umpebc_marcs do |t|
      t.string :doi, null: false, unique: true
      t.binary :mrc
      t.integer :year

      t.timestamps
    end
  end
end
