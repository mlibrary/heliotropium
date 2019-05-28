class CreateIdentifiers < ActiveRecord::Migration[5.2]
  def change
    create_table :identifiers do |t|
      t.string :name, null: false

      t.timestamps
    end
    add_index :identifiers, :name
  end
end
