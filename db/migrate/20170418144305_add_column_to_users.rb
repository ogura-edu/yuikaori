class AddColumnToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :screen_name, :string
    add_column :users, :image, :string
  end
end
