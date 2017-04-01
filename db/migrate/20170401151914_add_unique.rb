class AddUnique < ActiveRecord::Migration[5.0]
  def change
    add_column :pictures, :article_url, :string
    add_column :videos, :article_url, :string
    
    add_index :members, :member, unique: true
    add_index :events, :event, unique: true
    add_index :tags, :tag, unique: true
  end
end
