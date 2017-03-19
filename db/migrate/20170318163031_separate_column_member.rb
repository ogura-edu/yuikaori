class SeparateColumnMember < ActiveRecord::Migration[5.0]
  def change
    remove_column :pictures, :member, :string
    add_column :pictures, :member_id, :integer
    add_column :pictures, :event_id, :integer
    add_column :videos, :member_id, :integer
    add_column :videos, :event_id, :integer
    
    create_table :members do |t|
      t.string :member
    end
    
    create_table :events do |t|
      t.string :event
    end
  end
end
