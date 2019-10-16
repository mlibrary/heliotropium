class AddSelectedToCatalogMarcs < ActiveRecord::Migration[5.2]
  def change
    add_column :catalog_marcs, :selected, :boolean, null:false, default: false
  end
end
