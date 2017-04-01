class Scrape::Downloader
  def initialize(dir_name)
    @dir_name = dir_name
  end
  
  def save_media(media_type, url, article_url, date, member_id, event_id, tmp)
    filepath = "#{@dir_name}#{File.basename(url)}"
    
    if Picture.find_by_address(filepath) || Video.find_by_address(filepath)
      puts "#{filepath} has already been saved or deleted"
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
    
    if File.exist?(fullpath)
      puts "#{filepath} exists"
      return
    end
    
    Scrape::Helper.mkdir_if_not_exist(fullpath)
    
    puts "download #{filepath}"
    open(fullpath, Scrape::Helper.write_mode(url)) do |output|
      begin
        open(url) do |data|
          output.write(data.read)
        end
      rescue OpenURI::HTTPError
        puts "#{filepath} was deleted from server"
      end
    end
    File.utime(date, date, fullpath)
  end
end
