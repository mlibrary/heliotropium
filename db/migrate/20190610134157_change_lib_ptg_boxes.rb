class ChangeLibPtgBoxes < ActiveRecord::Migration[5.2]
  def change
    change_table :lib_ptg_boxes do |t|
      t.rename :type, :flavor
    end
  end
end
