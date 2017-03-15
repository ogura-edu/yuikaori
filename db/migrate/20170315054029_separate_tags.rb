class SeparateTags < ActiveRecord::Migration[5.0]
  def change
    remove_column :pictures, :tag, :string
    remove_column :videos, :tag, :string
  end
end
