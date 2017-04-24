class ChangeColumnToReferences < ActiveRecord::Migration[5.0]
  def change
    remove_column :pictures, :member_id, :integer, null: false
    remove_column :pictures, :event_id, :integer, null: false
    remove_column :videos, :member_id, :integer, null: false
    remove_column :videos, :event_id, :integer, null: false
    add_reference :pictures, :member, index: true, null: false
    add_reference :pictures, :event, index: true
    add_reference :videos, :member, index: true, null: false
    add_reference :videos, :event, index: true
  end
end
