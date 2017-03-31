class DeleteRemovedAddresses < ActiveRecord::Migration[5.0]
  def up
    drop_table :removed_addresses
    
    add_column :pictures, :removed, :boolean, default: false, null: false
    add_column :videos, :removed, :boolean, default: false, null: false
  end
  
  def down
    create_table :removed_addresses, id: false do |t|
      t.string :address
    end
    
    add_index :removed_addresses, :address, unique: true
    
    remove_column :pictures, :removed
    remove_column :videos, :removed
  end
end
