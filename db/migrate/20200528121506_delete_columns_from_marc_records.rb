class DeleteColumnsFromMarcRecords < ActiveRecord::Migration[5.2]
  def change
    remove_column :marc_records, :raw
    remove_column :marc_records, :replaced
  end
end
