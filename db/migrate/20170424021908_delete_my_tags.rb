class DeleteMyTags < ActiveRecord::Migration[5.0]
  def up
    drop_table :tags
    drop_table :pictures_tags
    drop_table :tags_videos
  end
  
  def down
    create_table :tags do |t|
      t.string :tag
    end
    create_table :pictures_tags, id: false do |t|
      t.integer :picture_id
      t.integer :tag_id
    end
    create_table :tags_videos, id: false do |t|
      t.integer :video_id
      t.integer :tag_id
    end
    
    add_index :tags, :tag, unique: true
  end
end
