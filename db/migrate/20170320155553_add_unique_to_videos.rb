class AddUniqueToVideos < ActiveRecord::Migration[5.0]
  def change
    add_index :videos, :address, unique: true
  end
end
