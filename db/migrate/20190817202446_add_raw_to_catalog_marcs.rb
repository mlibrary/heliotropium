class AddRawToCatalogMarcs < ActiveRecord::Migration[5.2]
  def change
    add_column :catalog_marcs, :raw, :binary
  end
end
