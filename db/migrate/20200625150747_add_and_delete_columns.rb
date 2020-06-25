class AddAndDeleteColumns < ActiveRecord::Migration[5.2]
  def change
    remove_column :kbart_files, :year
    remove_column :kbart_marcs, :year
    add_column :kbart_marcs, :file, :string
    add_column :kbart_marcs, :updated, :date
  end
end
