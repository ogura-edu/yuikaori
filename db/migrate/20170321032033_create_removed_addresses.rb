class CreateRemovedAddresses < ActiveRecord::Migration[5.0]
  def change
    create_table :removed_addresses, id: false do |t|
      t.string :address
    end
    
    add_index :removed_addresses, :address, unique: true
    
    add_column :pictures, :tmp, :boolean, default: false, null: false
    add_column :videos, :tmp, :boolean, default: false, null: false
  end
end
