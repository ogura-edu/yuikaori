class ChangeColumnNameMembersAndEvents < ActiveRecord::Migration[5.0]
  def change
    rename_column :members, :member, :name
    rename_column :events, :event, :name
  end
end
