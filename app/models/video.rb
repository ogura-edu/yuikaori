class Video < ApplicationRecord
  has_and_belongs_to_many :tags
  belongs_to :member
  belongs_to :event
  
  def ss_address
    attributes['address'].gsub(%r{\..*?$}, '.jpg')
  end
  
  def screenshot
    filepath = Settings.media.root + ss_address
    if File.exist?(filepath)
      puts "screenshot #{filepath} already exists."
      return
    end
    movie = FFMPEG::Movie.new(address)
    movie.screenshot(filepath)
  end
end
