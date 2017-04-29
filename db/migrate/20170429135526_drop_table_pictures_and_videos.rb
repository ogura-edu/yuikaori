class DropTablePicturesAndVideos < ActiveRecord::Migration[5.0]
  def change
    drop_table :pictures
    drop_table :videos
  end
end
