class Scrape::OfficialSiteCrawler
  def initialize(url, *links)
    uri = Addressable::URI.parse(url).normalize
    linked_hosts = links.map{|domain| Addressable::URI.parse(domain).normalize.host}
    @cache = []
    @top_page = uri
    @http = Net::HTTP.new(uri.host)
    @allowed_hosts = [ uri.host, *linked_hosts ]
    @downloader = Scrape::Downloader.new("official_site/")
  end
  
  def validate
    raise ArgumentError, '追跡済みのURLは指定しないでください' if skip_domains.include?(@top_page.host)
  end
  
  def crawl(member_id:)
    crawl_media(member_id, 1, true)
  end
  
  def manually_crawl(params:)
    crawl_media(params[:member_id], params[:event_id], true, params[:depth_limit])
  end
  
  private
  
  def crawl_media(member_id, event_id, tmp, depth_limit = false)
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
        
        doc.xpath('//link[@rel="stylesheet"]').each do |link_tag|
          puts 'cssはまだでーす'
        end
      end
    end
  end
  
  def extract_data(tag, page_url, type, member_id, event_id, tmp)
    media_url = url(page_url, tag.attribute('src').value)
    # インスタンス変数@cacheを参照してチェック済みのURLをスキップ
    return if @cache.include?(media_url)
    
    uri = Addressable::URI.parse(media_url).normalize
    date = Time.parse(response_header(uri)['last-modified'] || Time.now.to_s)
    filepath = "official_site/#{uri.host}#{uri.path}"
    @downloader.save_media(type, uri.to_s, page_url, date, member_id, event_id, tmp, filepath)
    @cache << media_url
  end
  
  def url(current_url, src)
    if absolute_path?(src)
      return src
    else
      base_uri = Addressable::URI.parse(current_url).normalize
      return (base_uri + src).to_s
    end
  end
  
  def allowed?(str)
    @allowed_hosts.each do |domain|
      return true if str.match(domain)
    end
    return false
  end
  
  def absolute_path?(str)
    Addressable::URI.parse(str).scheme != nil
  end
  
  def response_header(uri)
    if @http.address == uri.host
      http = @http
    else
      http = Net::HTTP.new(uri.host)
    end
    return http.head(uri.path)
  end
  
  def skip_domains
    Settings.official_site.regular_crawl.map{|obj| obj.domain}
  end
end
