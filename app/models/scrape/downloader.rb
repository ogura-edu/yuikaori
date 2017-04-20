class Scrape::Downloader
  def initialize(dir_name)
    @dir_name = "images/#{dir_name}"
  end
  
  def save_youtube(id, uri, article_uri, member_id, event_id, tmp)
    filepath = "images/youtube/#{id}.mp4"
    fullpath = Scrape::Helper.fullpath(filepath)
    tmpfile = "tmp/#{id}.mp4"
    obj = S3_BUCKET.object(filepath)
    
    if Video.find_by_address(fullpath)
      puts "#{uri} has been already saved or deleted"
      return
    elsif obj.exists?
      puts "#{fullpath} already exists"
      return
    end
    
    puts "download #{uri} to #{fullpath}"
    options = {
      output: tmpfile,
      format: :best,
      no_warnings: true
    }
    YoutubeDL.download(uri.to_s, options)
    obj.put(body: File.open(tmpfile))
    File.delete(tmpfile)
    
    Nokogiri::HTML.parse(open(uri)).xpath('//strong[@class="watch-time-text"]').text.match %r{(\d+/\d+/\d+)}
    date = Time.parse($1)
    
    video = Video.create(
      address: fullpath,
      article_url: article_uri.to_s,
      member_id: member_id,
      event_id: event_id,
      date: date.strftime("%Y-%m-%d %H:%M:%S"),
      created_at: Time.now.strftime("%Y-%m-%d %H:%M:%S"),
      updated_at: Time.now.strftime("%Y-%m-%d %H:%M:%S"),
      tmp: tmp
    )
    video.screenshot
  end
  
  def save_media(media_type, uri, article_uri, date, member_id, event_id, tmp, filepath = nil)
    # filepathを指定したい時は指定してもらう感じで。
    filepath = filepath ? "images/#{filepath}" : "#{@dir_name}#{File.basename(uri)}"
    fullpath = Scrape::Helper.fullpath(filepath)
    
    # そもそもダウンロードしないものを弾く
    if Settings.extname.images.exclude?(File.extname(uri)) && Settings.extname.videos.exclude?(File.extname(uri))
      puts "#{uri}'s extension is not allowed to download"
      return
    elsif media_type == :image && Picture.find_by_address(fullpath)
      puts "#{uri} has already been saved or deleted"
      return
    elsif media_type == :video && Video.find_by_address(fullpath)
      puts "#{uri} has already been saved or deleted"
      return
    end
    
    download(filepath, fullpath, uri)
    
    case media_type
    when :image
      Picture.create(
        address: fullpath,
        article_url: article_uri.to_s,
        member_id: member_id,
        event_id: event_id,
        date: date.strftime("%Y-%m-%d %H:%M:%S"),
        created_at: Time.now.strftime("%Y-%m-%d %H:%M:%S"),
        updated_at: Time.now.strftime("%Y-%m-%d %H:%M:%S"),
        tmp: tmp
      )
    when :video
      video = Video.create(
        address: fullpath,
        article_url: article_uri.to_s,
        member_id: member_id,
        event_id: event_id,
        date: date.strftime("%Y-%m-%d %H:%M:%S"),
        created_at: Time.now.strftime("%Y-%m-%d %H:%M:%S"),
        updated_at: Time.now.strftime("%Y-%m-%d %H:%M:%S"),
        tmp: tmp
      )
      video.screenshot
    end
  end
  
  private
  
  def download(filepath, fullpath, uri)
    obj = S3_BUCKET.object(filepath)
    
    # 既にダウンロードしてある場合はスキップ
    if obj.exists?
      puts "#{fullpath} already exists"
      return
    end
    
    puts "download #{uri} to #{fullpath}"
    obj.put(body: open(uri))
  end
end
