class AddContentToCatalogMarcs < ActiveRecord::Migration[5.2]
  def change
    add_column :catalog_marcs, :content, :binary
  end
end
