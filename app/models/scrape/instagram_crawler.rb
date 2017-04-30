class Scrape::InstagramCrawler
  include Capybara::DSL
  
  attr_accessor :errors
  
  def initialize(params)
    ::Capybara.current_driver = :poltergeist
    ::Capybara.javascript_driver = :poltergeist
    ::Capybara.default_max_wait_time = 20
    ::Capybara.app_host = 'https://www.instagram.com/?hl=eg'
    ::Capybara.register_driver :poltergeist do |app|
      ::Capybara::Poltergeist::Driver.new(app, inspector: true, js_errors: false)
    end
    @yaml_file = S3_BUCKET.object('config/instagram.yml')
    
    member_id = params[:member_id]
    event_id = params[:event_id]
    new_event = params[:event_attributes]
    tag_list = params[:tag_list]
    tmp = params[:tmp]
    @article_url = params[:article_url].try(:gsub, %r{\?.*$}, '')
    open(@article_url).read.match %r{\(@(.+?)\)} rescue nil
    @instaID = params[:instaID] || $1
    @downloader = Scrape::Downloader.new("instagram/#{@instaID}/", member_id, event_id, new_event, tag_list, tmp)
  end
  
  def validate
    if skip_IDs.include?(@instaID)
      @errors = '追跡済みのユーザは指定しないでください'
      return false
    elsif @instaID.nil? || !@article_url.match(%r{https://www.instagram.com/p/.+?/$})
      @errors = '無効なURLです'
      return false
    end
    true
  end
  
  def crawl(type: :recent)
    puts "visit user page of #{@instaID}"
    visit("#{@instaID}?hl=eg")
    case type
    when :all
      @article_urls = load_yaml
      check_recent_posts
      @article_urls.each do |article_url|
        parse_post(article_url)
      end
      save_yaml
    when :recent
      @article_urls = []
      check_recent_posts
      @article_urls.each do |article_url|
        parse_post(article_url)
      end
      save_yaml
    end
  end
  
  def manually_crawl
    parse_post(@article_url)
  end
  
  private
  
  def load_yaml
    puts "load from yaml file 'config/instagram.yml'"
    YAML.load(@yaml_file.get.body.read)
  end
  
  def save_yaml
    puts "save to yaml file 'config/instagram.yml'"
    @yaml_file.put(body: @article_urls.to_yaml) rescue puts $!
  end
  
  def check_recent_posts
    puts 'checking recent posts ...'
    click_link 'Load more'
    all(:xpath, '//a[@class="_8mlbc _vbtk2 _t5r8b"]').each do |result|
      @article_urls << result[:href].gsub(/\?.*$/, "")
    end
    @article_urls.uniq!
  end
  
  def skip_IDs
    Settings.instagram.regular_crawl.map{|obj| obj.ID}
  end
  
  def parse_post(article_url)
    doc = Nokogiri::HTML.parse(open("#{article_url}?hl=ja"))
    
    datestr = doc.at('meta[@property="og:title"]').attribute('content').value
    if datestr.include?('午前')
      date = Time.local(*datestr.scan(/\d+/))
    else
      date = Time.local(*datestr.scan(/\d+/))+(60*60*12)
    end
    
    if doc.at('//meta[@content="video"]')
      video_url = doc.at('//meta[@property="og:video:secure_url"]').attribute('content').value
      @downloader.save_media(:video, video_url, article_url, date)
    else
      image_url = doc.at('//meta[@property="og:image"]').attribute('content').value
      @downloader.save_media(:image, image_url, article_url, date)
    end
  end
end
