class CreateUuids < ActiveRecord::Migration[5.2]
  def change
    create_table :uuids do |t|
      t.binary :packed, null: false, index: true, unique: true, limit: 16.bytes
      t.string :unpacked, null: false, index: true, unique: true, limit: 36

      t.timestamps
    end
  end
end
