class ChangeUpdatedType < ActiveRecord::Migration[5.2]
  def change
    change_column :marc_records, :updated, :date
  end
end
