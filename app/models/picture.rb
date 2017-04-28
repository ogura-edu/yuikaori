class Picture < ApplicationRecord
  include MediaContentBase
  
  def self.remove(ids)
    pictures = where(id: ids)
    pictures.update_all(removed: true)
    pictures.each do |picture|
      S3_BUCKET.object(picture.s3_address).delete rescue puts "#{picture.s3_address} is maybe not exists."
    end
  end
end
