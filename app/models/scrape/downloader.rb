class Scrape::Downloader
  def initialize(dir_name)
    @dir_name = dir_name
  end
  
  def save_media(media_type, url, article_url, date, member_id, event_id, tmp, filepath = nil)
    # filepathを指定したい時は指定してもらう感じで。
    filepath ||= "#{@dir_name}#{File.basename(url)}"
    
    # そもそもダウンロードしないものを弾く
    if Settings.extname.images.exclude?(File.extname(url)) && Settings.extname.videos.exclude?(File.extname(url))
      puts "#{url}'s extension is not allowed to download"
      return
    elsif Picture.find_by_address(filepath) || Video.find_by_address(filepath)
      puts "#{url} has already been saved or deleted"
      return
    end
    
    download(filepath, url, date)
    
    case media_type
    when :image
      Picture.create(
        address: filepath,
        article_url: article_url,
        member_id: member_id,
        event_id: event_id,
        date: date.strftime("%Y-%m-%d %H:%M:%S"),
        created_at: Time.now.strftime("%Y-%m-%d %H:%M:%S"),
        updated_at: Time.now.strftime("%Y-%m-%d %H:%M:%S"),
        tmp: tmp
      )
    when :video
      Video.create(
        address: filepath,
        article_url: article_url,
        member_id: member_id,
        event_id: event_id,
        date: date.strftime("%Y-%m-%d %H:%M:%S"),
        created_at: Time.now.strftime("%Y-%m-%d %H:%M:%S"),
        updated_at: Time.now.strftime("%Y-%m-%d %H:%M:%S"),
        tmp: tmp
      )
    end
  end
  
  private
  
  def download(filepath, url, date)
    fullpath = Scrape::Helper.fullpath(filepath)
    
    # 既にダウンロードしてある場合はスキップ
    if File.exist?(fullpath)
      puts "#{filepath} already exists"
      return
    end
    
    Scrape::Helper.mkdir(fullpath)
    
    puts "download #{url} to #{fullpath}"
    open(fullpath, Scrape::Helper.write_mode(url)) do |output|
      begin
        open(url) do |data|
          output.write(data.read)
        end
      rescue OpenURI::HTTPError
        puts "#{url} was deleted from server"
      end
    end
    File.utime(date, date, fullpath)
  end
end
