class AddFolderToKbartFiles < ActiveRecord::Migration[5.2]
  def change
    add_column :kbart_files, :folder, :string, null:false
  end
end
