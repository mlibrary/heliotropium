class CreateLibPtgBoxes < ActiveRecord::Migration[5.2]
  def change
    create_table :lib_ptg_boxes do |t|
      t.string :name, null: false, index: true, unique: true
      t.string :type, null: false, default: "year"
      t.integer :month, null: false, default: 0
      t.date :updated, null: false, default: Time.new(1970, 1, 1)

      t.timestamps
    end
  end
end
