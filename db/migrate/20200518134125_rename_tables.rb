class RenameTables < ActiveRecord::Migration[5.2]
  def change
    rename_table :umpebc_files, :marc_files
    rename_table :umpebc_kbarts, :kbart_files
    rename_table :catalog_marcs, :marc_records
    rename_table :umpebc_marcs, :kbart_marcs
  end
end
