class Scrape::Downloader
  def initialize(dir_name)
    @dir_name = "#{Settings.media.url}#{dir_name}"
  end
  
  def save_youtube(id, uri, article_uri, member_id, event_id, tmp)
    filepath = "youtube/#{id}.mp4"
    fullpath = Scrape::Helper.fullpath(filepath)
    
    if Video.find_by_address(filepath)
      puts "#{uri} has been already saved or deleted"
      return
    elsif File.exist?(fullpath)
      puts "#{filepath} already exists"
      return
    end
    
    # ディレクトリはgem側で作成してくれる
    
    puts "download #{uri} to #{filepath}"
    options = {
      output: fullpath,
      format: :best,
      no_warnings: true
    }
    YoutubeDL.download(uri.to_s, options)
    date = File.mtime(fullpath)
    
    video = Video.create(
      address: filepath,
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
    filepath ||= "#{@dir_name}#{File.basename(uri)}"
    
    # そもそもダウンロードしないものを弾く
    if Settings.extname.images.exclude?(File.extname(uri)) && Settings.extname.videos.exclude?(File.extname(uri))
      puts "#{uri}'s extension is not allowed to download"
      return
    elsif media_type == :image && Picture.find_by_address(filepath)
      puts "#{uri} has already been saved or deleted"
      return
    elsif media_type == :video && Video.find_by_address(filepath)
      puts "#{uri} has already been saved or deleted"
      return
    end
    
    download(filepath, uri, date)
    
    case media_type
    when :image
      Picture.create(
        address: filepath,
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
        address: filepath,
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
  
  def download(filepath, uri, date)
    fullpath = Scrape::Helper.fullpath(filepath)
    
    # 既にダウンロードしてある場合はスキップ
    if File.exist?(fullpath)
      puts "#{filepath} already exists"
      return
    end
    
    Scrape::Helper.mkdir(fullpath)
    
    puts "download #{uri} to #{fullpath}"
    open(fullpath, Scrape::Helper.write_mode(uri)) do |output|
      begin
        open(uri) do |data|
          output.write(data.read)
        end
      rescue OpenURI::HTTPError
        puts "#{uri} was deleted from server"
      end
    end
    File.utime(date, date, fullpath)
  end
end
