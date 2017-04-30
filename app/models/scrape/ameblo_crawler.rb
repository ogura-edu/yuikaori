class Scrape::AmebloCrawler
  attr_accessor :errors
  
  def initialize(params)
    member_id = params[:member_id]
    event_id = params[:event_id]
    new_event = params[:event_attributes]
    tag_list = params[:tag_list]
    tmp = params[:tmp]
    @article_url = params[:article_url]
    @article_url.match %r{http://ameblo.jp/(.+?)/entry-\d+?\.html$} rescue nil
    @amebaID = params[:amebaID] || $1
    @host = "http://ameblo.jp/#{@amebaID}/"
    @downloader = Scrape::Downloader.new("ameblo/#{@amebaID}/", member_id, event_id, new_event, tag_list, tmp)
  end
  
  def validate
    if @amebaID.nil?
      @errors = '無効なURLです'
      return false
    elsif skip_IDs.include?(@amebaID)
      @errors = '追跡済みのユーザは指定しないでください'
      return false
    end
    true
  end
  
  def crawl(type: :recent)
    case type
    when :all
      all_entrylist.each do |entrylist_url|
        single_crawl(entrylist_url)
      end
    when :recent
      single_crawl("#{@host}entrylist.html")
    end
  end
  
  def manually_crawl
    parse_article
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
  
  def single_crawl(url)
    Dir.mkdir('tmp/anemone/') unless Dir.exist?('tmp/anemone')
    options = {
      depth_limit: 1,
      delay: 2,
      storage: Anemone::Storage.PStore("tmp/#{@amebaID}.dmp")
    }
    Anemone.crawl(url, options) do |anemone|
      anemone.focus_crawl do |page|
        page.links.keep_if do |link|
          link.to_s.match %r{http://ameblo.jp/#{@amebaID}/entry-\d+?\.html$}
        end
      end
      
      begin
        anemone.on_every_page do |page|
          puts "image on #{page.url} :"
          @article_url = page.url
          parse_article
        end
      rescue => ex
        puts ex
        puts 'please retry'
      end
    end
  end

  def parse_article
    doc = Nokogiri::HTML.parse(open(@article_url))
    doc.xpath('//div[@class="articleText" or  @class="subContentsInner"]//a/img').each do |img|
      image_url = img.attribute('src').value.gsub(/t[\d]*_/, 'o').gsub(/\?.*$/, '')
      break if File.extname(image_url) == ".gif"
      
      datestr = image_url.gsub(/.*user_images\/(.*?)\//, '\1')
      dateary = [datestr.slice(0,4), datestr.slice(4,2), datestr.slice(6,2)]
      date = Time.local(*dateary)
      
      @downloader.save_media(:image, image_url, @article_url, date)
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
