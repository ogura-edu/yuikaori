class Video < Media
  
  def s3_ss_address
    s3_address.gsub(%r{\.[^.]*?$}, '.jpg')
  end
  
  def ss_address
    attributes['address'].gsub(%r{\.[^.]*?$}, '.jpg')
  end
  
  def screenshot
    ss = S3_BUCKET.object(s3_ss_address)
    tmp_ss = "tmp/screenshot.jpg"
    if ss.exists?
      puts "screenshot #{ss_address} already exists."
      return
    end
    movie = FFMPEG::Movie.new(address)
    movie.screenshot(tmp_ss)
    ss.put(body: File.open(tmp_ss))
    File.delete(tmp_ss)
  end
end
