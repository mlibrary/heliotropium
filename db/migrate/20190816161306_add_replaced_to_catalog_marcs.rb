class AddReplacedToCatalogMarcs < ActiveRecord::Migration[5.2]
  def change
    add_column :catalog_marcs, :replaced, :boolean, null:false, default: false
  end
end
