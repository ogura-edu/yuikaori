class CreatePictures < ActiveRecord::Migration[5.0]
  def change
    create_table :pictures do |t|
      t.string :member
      t.string :address
      t.date :date
      t.string :tag

      t.timestamps
    end
  end
end
