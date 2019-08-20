class AddVerifiedToUmpebcKbarts < ActiveRecord::Migration[5.2]
  def change
    add_column :umpebc_kbarts, :verified, :boolean, default: false
  end
end
