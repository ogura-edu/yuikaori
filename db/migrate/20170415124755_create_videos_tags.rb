class CreateVideosTags < ActiveRecord::Migration[5.0]
  def change
    create_table :tags_videos, id: false do |t|
      t.integer :video_id
      t.integer :tag_id
    end
  end
end
