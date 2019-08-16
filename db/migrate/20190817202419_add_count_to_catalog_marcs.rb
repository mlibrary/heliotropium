class AddCountToCatalogMarcs < ActiveRecord::Migration[5.2]
  def change
    add_column :catalog_marcs, :count, :integer, default: 0
  end
end
