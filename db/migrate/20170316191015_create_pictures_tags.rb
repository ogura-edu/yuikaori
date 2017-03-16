class CreatePicturesTags < ActiveRecord::Migration[5.0]
  def change
    remove_column :tags, :picture_id, :integer
    remove_column :tags, :created_at, :date
    remove_column :tags, :updated_at, :date
    
    create_table :pictures_tags, id:false do |t|
      t.integer :picture_id
      t.integer :tag_id
    end
  end
end
