class Scrape::NewsSiteCrawler
  def initialize(params)
    @member_id = params[:member_id].to_i
    @event_id = params[:event_id].to_i
    @article_uri = Addressable::URI.parse(params[:article_url]).normalize
    @http = Net::HTTP.new(@article_uri.host)
    @downloader = Scrape::Downloader.new('')
  end
  
  def validate
    raise ArgumentError, 'パーサが未作成のサイトです。管理者に申請してください' unless registered_domain
  end
  
  def manually_crawl
    puts "parsing #{@article_uri} ..."
    method_name = snakecase(registered_domain)
    doc = Nokogiri::HTML.parse(open(@article_uri))
    send(method_name, doc)
  end
  
  private
 
  def snakecase(str)
    str.gsub('', '').
    tr('.-', '_').
    downcase
  end
  
  def youtube(doc)
    puts 'checking youtube embedded video ...'
    doc.xpath('//iframe').each do |youtube_tag|
      url = youtube_tag.attribute('src').value
      next unless url.match('youtube')
      id = File.basename(URI.parse(url).path)
      video_uri = URI.parse(url.gsub('embed/', 'watch/?v='))
      @downloader.save_youtube(id, video_uri, @article_uri, @member_id, @event_id, true)
    end
  end
  
  define_method 'natalie_mu/music/news' do |doc|
    date = doc.xpath('//p[@class="NA_date"]/time').text.tr('年月日', '/')
    date = Time.parse(date)
    doc.xpath('//article//span[@class="NA_thumb"]').each do |thumb|
      thumb.attribute('style').value.match(%r{url\((.*?)\)})
      image_url = Scrape::Helper.url(@article_uri, $1.gsub('list_thumb_inbox', 'xlarge'))
      uri = Addressable::URI.parse(image_url)
      filepath = "#{uri.host}#{uri.path}"
      @downloader.save_media(:image, uri, @article_uri, date, @member_id, @event_id, true, filepath)
    end
    youtube(doc)
  end
  
  define_method 'natalie_mu/music/pp' do |doc|
    date = doc.xpath('html/head//script').text.match(%r{"datePublished":"(.*?)"})
    date = Time.parse($1)
    Anemone.crawl(@article_uri, {depth_limit:1}) do |anemone|
      anemone.focus_crawl do |page|
        page.links.keep_if do |link|
          link.to_s.match(@article_uri)
        end
      end
      anemone.on_every_page do |page|
        doc = Nokogiri::HTML.parse(page.body)
        doc.xpath('//div[@id="sp-left"]//img').each do |img_tag|
          image_url = Scrape::Helper.url(page.url, img_tag.attribute('src').value.gsub(%r{(photo\d*)s}, '\1'))
          uri = Addressable::URI.parse(image_url)
          filepath = "#{uri.host}#{uri.path}"
          @downloader.save_media(:image, uri, @article_uri, date, @member_id, @event_id, true, filepath)
        end
        youtube(doc)
      end
    end
  end
  
  define_method 'www_animatetimes_com/news' do |doc|
    date = doc.xpath('//div[@class="news-date"]').text
    date = Time.parse(date)
    doc.xpath('//div[@class="entry"]//img').each do |img_tag|
      image_url = Scrape::Helper.url(@article_uri, img_tag.attribute('src').value)
      uri = Addressable::URI.parse(image_url)
      filepath = "#{uri.host}#{uri.path}"
      @downloader.save_media(:image, uri, @article_uri, date, @member_id, @event_id, true, filepath)
    end
    youtube(doc)
  end
  
  define_method 'top_tsite_jp/news' do |doc|
    date = doc.xpath('//p[@class="c_article_date"]').text.gsub(%r{(\d+)年(\d+)月(\d+)日.*}, '\1-\2-\3')
    date = Time.parse(date)
    doc.xpath('//div[@class="gallery_thumb"]//img').each do |img_tag|
      image_url = Scrape::Helper.url(@article_uri, img_tag.attribute('src').value)
      uri = Addressable::URI.parse(image_url)
      filepath = "#{uri.host}#{uri.path}"
      @downloader.save_media(:image, uri, @article_uri, date, @member_id, @event_id, true, filepath)
    end
    youtube(doc)
  end
  
  define_method 'www_barks_jp/news' do |doc|
    date = doc.xpath('//p[@class="article-postdate"]').text
    date = Time.parse(date)
    Anemone.crawl(@article_uri, {depth_limit:1}) do |anemone|
      anemone.focus_crawl do |page|
        page.links.keep_if do |link|
          # 記事情報(id)がURLクエリ文字列として入っているため、escape処理をかませている。
          link.to_s.match(Regexp.escape(@article_uri))
        end
      end
      anemone.on_every_page do |page|
        doc = Nokogiri::HTML.parse(page.body)
        doc.xpath('//section[@class="article-body"]//img').each do |img_tag|
          image_url = Scrape::Helper.url(page.url, img_tag.attribute('src').value)
          uri = Addressable::URI.parse(image_url)
          filepath = "#{uri.host}#{uri.path}"
          @downloader.save_media(:image, uri, @article_uri, date, @member_id, @event_id, true, filepath)
        end
        youtube(doc)
      end
    end
  end
  
  def registered_domain
    Settings.news_site.each do |domain|
      return domain if @article_uri.to_s.match(domain)
    end
    nil
  end
end
