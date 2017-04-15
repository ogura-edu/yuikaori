class Scrape::AmebloCrawler
  def initialize(url)
    @amebaID = url.gsub(%r{http://ameblo.jp/(.*?)/.*}, '\1')
    @host = "http://ameblo.jp/#{@amebaID}/"
    @downloader = Scrape::Downloader.new("ameblo/#{@amebaID}/")
  end
  
  def validate
    raise ArgumentError, '追跡済みのIDは指定しないでください' if skip_IDs.include?(@amebaID)
  end
  
  def crawl(member_id:, type: :recent)
    case type
    when :all
      all_entrylist.each do |entrylist_url|
        single_crawl(entrylist_url, member_id)
      end
    when :recent
      single_crawl("#{@host}entrylist.html", member_id)
    end
  end
  
  def manually_crawl(params:)
    parse_article(params[:article_url], params[:member_id], params[:event_id], true)
  end
  
  private
  
  def all_entrylist
    article_num = 0
    urls = []
    doc = Nokogiri::HTML.parse(open(@host))
    doc.xpath('//div[@class="skinMenu archiveMenu"]/div[1]/div[2]/ul/li/a').each do |archive|
      article_num = article_num + archive.text.gsub(/.*\( ([\d]*) \)/, '\1').to_i
    end
    1.upto(article_num / 20 + 1) do |i|
      urls << "#{@host}entrylist-#{i}.html"
    end
    return urls
  end
  
  def single_crawl(url, member_id)
    Dir.mkdir('tmp/anemone/') unless Dir.exist?('tmp/anemone')
    options = {
      depth_limit: 1,
      delay: 2,
      storage: Anemone::Storage.PStore("tmp/anemone/#{@amebaID}.dmp")
    }
    Anemone.crawl(url, options) do |anemone|
      anemone.focus_crawl do |page|
        page.links.keep_if do |link|
          link.to_s.match(/#{@amebaID}\/entry-[\d]*\.html/)
        end
      end
      
      begin
        anemone.on_every_page do |page|
          puts "image on #{page.url} :"
          parse_article(page.url, member_id, 1, false)
        end
      rescue => ex
        puts ex
        puts 'please retry'
      end
    end
  end

  def parse_article(article_url, member_id, event_id, tmp)
    doc = Nokogiri::HTML.parse(open(article_url))
    doc.xpath('//div[@class="articleText" or  @class="subContentsInner"]//a/img').each do |img|
      image_url = img.attribute('src').value.gsub(/t[\d]*_/, 'o').gsub(/\?.*$/, '')
      break if File.extname(image_url) == ".gif"
      
      puts image_url
      
      datestr = image_url.gsub(/.*user_images\/(.*?)\//, '\1')
      dateary = [datestr.slice(0,4), datestr.slice(4,2), datestr.slice(6,2)]
      date = Time.local(*dateary)
      
      @downloader.save_media(:image, image_url, article_url, date, member_id, event_id, tmp)
    end
  end
  
  def skip_IDs
    array = []
    (Settings.ameblo.regular_crawl + Settings.ameblo.stopped_updating).each do |obj|
      array << obj.ID
    end
    return array
  end
end
