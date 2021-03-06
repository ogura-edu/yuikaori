class Scrape::OfficialSiteCrawler
  def initialize(url, *links)
    uri = Addressable::URI.parse(url).normalize
    linked_hosts = links.map{|link| Addressable::URI.parse(link).normalize.host}
    @cache = []
    @top_page = uri
    @http = Net::HTTP.new(uri.host)
    @allowed_hosts = [ uri.host, *linked_hosts ]
    @downloader = Scrape::Downloader.new('')
  end
  
  def validate
    raise ArgumentError, '追跡済みのURLは指定しないでください' if skip_hosts.include?(@top_page.host)
  end
  
  def crawl(member_id:)
    crawl_media(member_id, 1, true, false)
  end
  
  def manually_crawl(params:)
    crawl_media(params[:member_id], params[:event_id], true, params[:depth_limit].to_i)
  end
  
  private
  
  def crawl_media(member_id, event_id, tmp, depth_limit)
    options = {
      depth_limit: depth_limit,
      delay: 2,
      obey_robots_txt: true,
      storage: Anemone::Storage.PStore("tmp/anemone/#{@top_page.host}.dmp")
    }
    
    Anemone.crawl(@top_page, options) do |anemone|
      anemone.skip_links_like(/PHPSESSID/)
      
      anemone.focus_crawl do |page|
        page.links.keep_if do |link|
          allowed?(link.to_s)
        end
      end
      
      anemone.on_every_page do |page|
        puts '-----------------------------------------------'
        puts "checking #{page.url} ..."
        doc = Nokogiri::HTML.parse(page.body)
        
        doc.xpath('//img').each do |img_tag|
          extract_data(img_tag, page.url, :image, member_id, event_id, tmp)
        end
        
        doc.xpath('//video').each do |video_tag|
          extract_data(video_tag, page.url, :video, member_id, event_id, tmp)
        end
        
        # youtube公式が公開しているのはiframeタグだがこれを使っていないサイトもある模様
        # それらに関しては、扱いが面倒なので個別でyoutube動画を取得するページを用意することにする
        doc.xpath('//iframe').each do |youtube_tag|
          url = youtube_tag.attribute('src').value
          next unless url.match('youtube')
          id = File.basename(URI.parse(url).path)
          video_uri = URI.parse(url.gsub('embed/', 'watch/?v='))
          @downloader.save_youtube(id, video_uri, page.url, member_id, event_id, tmp)
        end
        
        doc.xpath('//link[@rel="stylesheet"]').each do |link_tag|
          puts 'cssはまだでーす'
        end
      end
    end
  end
  
  def extract_data(tag, page_url, type, member_id, event_id, tmp)
    media_url = Scrape::Helper.url(page_url, tag.attribute('src').value)
    # インスタンス変数@cacheを参照してチェック済みのURLをスキップ
    return if @cache.include?(media_url)
    
    uri = Addressable::URI.parse(media_url).normalize
    date = Time.parse(response_header(uri)['last-modified'] || Time.now.to_s)
    filepath = "#{uri.host}#{uri.path}"
    @downloader.save_media(type, uri, page_url, date, member_id, event_id, tmp, filepath)
    @cache << media_url
  end
  
  def allowed?(str)
    @allowed_hosts.each do |host|
      return true if str.match(host)
    end
    false
  end
  
  def response_header(uri)
    if @http.address == uri.host
      http = @http
    else
      http = Net::HTTP.new(uri.host)
    end
    http.head(uri.path)
  end
  
  def skip_hosts
    Settings.official_site.regular_crawl.map{|obj| obj.host}
  end
end
