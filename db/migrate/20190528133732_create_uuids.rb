class CreateUuids < ActiveRecord::Migration[5.2]
  def change
    create_table :uuids do |t|
      t.binary :packed
      t.string :unpacked

      t.timestamps
    end
  end
end
