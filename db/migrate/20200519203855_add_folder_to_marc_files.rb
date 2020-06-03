class AddFolderToMarcFiles < ActiveRecord::Migration[5.2]
  def change
    add_column :marc_files, :folder, :string, null:false
  end
end
