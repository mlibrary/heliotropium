class CreateCatalogMarcs < ActiveRecord::Migration[5.2]
  def change
    create_table :catalog_marcs do |t|
      t.string :folder, null: false
      t.string :file, null: false
      t.string :isbn
      t.string :doi
      t.binary :mrc
      t.datetime :updated, null: false, default: Time.new(1970, 1, 1)
      t.boolean :parsed, null: false, default: false

      t.timestamps
    end
    add_index :catalog_marcs, [:folder, :file], unique: true
  end
end
