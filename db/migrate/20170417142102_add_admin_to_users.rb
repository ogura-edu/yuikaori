class AddAdminToUsers < ActiveRecord::Migration[5.0]
  def up
    add_column :users, :admin, :boolean, default: false
    add_column :users, :approved, :boolean, default: false, null: false
    add_index  :users, :approved
  end
  
  def down
    removed_index  :users, :approved
    removed_column :users, :approved
    removed_column :users, :admin
  end
end
