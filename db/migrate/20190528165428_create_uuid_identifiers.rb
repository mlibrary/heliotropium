class CreateUuidIdentifiers < ActiveRecord::Migration[5.2]
  def change
    create_table :uuid_identifiers do |t|
      t.references :uuid, foreign_key: true
      t.references :identifier, foreign_key: true

      t.timestamps
    end
    add_index :uuid_identifiers, [:uuid_id, :identifier_id], unique: true
  end
end
