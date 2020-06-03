class AddFolderToKbartMarcs < ActiveRecord::Migration[5.2]
  def change
    add_column :kbart_marcs, :folder, :string, null:false
  end
end
