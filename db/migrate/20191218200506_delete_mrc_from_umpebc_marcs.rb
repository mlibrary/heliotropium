class DeleteMrcFromUmpebcMarcs < ActiveRecord::Migration[5.2]
  def change
    remove_column :umpebc_marcs, :mrc
  end
end
