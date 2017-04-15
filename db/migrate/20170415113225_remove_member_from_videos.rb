class RemoveMemberFromVideos < ActiveRecord::Migration[5.0]
  def change
    remove_column :videos, :member, :string
  end
end
