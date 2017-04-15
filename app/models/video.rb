class Video < ApplicationRecord
  belongs_to :member
  belongs_to :event
  
  def screenshot
    filepath = Settings.media.root + attributes['address'].gsub(%r{\..*$}, '.jpg')
    if File.exist?(filepath)
      puts "screenshot #{filepath} already exists."
      return
    end
    movie = FFMPEG::Movie.new(address)
    movie.screenshot(filepath)
  end
end
