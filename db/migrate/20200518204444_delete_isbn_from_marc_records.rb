class DeleteIsbnFromMarcRecords < ActiveRecord::Migration[5.2]
  def change
    remove_column :marc_records, :isbn
  end
end
