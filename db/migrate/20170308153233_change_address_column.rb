class ChangeAddressColumn < ActiveRecord::Migration[5.0]
  def change
    add_index :pictures, :address, unique: true
  end
end
