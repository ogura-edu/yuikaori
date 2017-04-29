class CreateMediaContents < ActiveRecord::Migration[5.0]
  def change
    create_table :media_contents do |t|
      t.integer :content_type, limit: 1, null: false
      t.string :address
      t.string :article_url
      t.date :date
      t.boolean :tmp, default: false, null: false
      t.boolean :removed, default: false, null: false
      t.references :member, limit: 1, null: false
      t.references :event
      
      t.timestamps
    end
    
    add_index :media_contents, :address, unique: true
  end
end
