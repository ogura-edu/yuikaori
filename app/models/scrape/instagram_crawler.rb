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
    
    @member_id = params[:member_id].to_i
    @event_id = params[:event_id].to_i
    @article_url = params[:article_url].gsub(%r{\?.*$}, '')
    open(@article_url).read.match %r{\(@(.+?)\)} rescue nil
    @instaID = params[:instaID] || $1
    @downloader = Scrape::Downloader.new("instagram/#{@instaID}/")
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
    login
    visit("#{@instaID}?hl=eg")
    case type
    when :all
      load_all_posts
      check_post
    when :recent
      check_post
    end
  end
  
  def manually_crawl
    parse_post(tmp: true)
  end
  
  private
  
  def login
    visit('/accounts/login/?hl=eg')
    page.fill_in 'username', with: Settings.instagram.username
    page.fill_in 'password', with: Settings.instagram.password
    click_button 'Log in'
  end
  
  def load_all_posts
    click_link 'Load more'
    y_offset = 0
    loop do
      page.execute_script("window.scrollBy(0,3000);")
      sleep(2)
      if y_offset == page.evaluate_script("window.pageYOffset;")
        break;
      else
        y_offset = page.evaluate_script("window.pageYOffset;")
      end
    end
  end
  
  def check_post
    all(:xpath, '//a[@class="_8mlbc _vbtk2 _t5r8b"]').each do |result|
      @article_url = result[:href].gsub(/\?.*$/, "")
      parse_post(tmp: false)
    end
  end
  
  def skip_IDs
    Settings.instagram.regular_crawl.map{|obj| obj.ID}
  end
  
  def parse_post(tmp:)
    doc = Nokogiri::HTML.parse(open("#{@article_url}?hl=ja"))
    
    datestr = doc.at('meta[@property="og:title"]').attribute('content').value
    if datestr.include?('午前')
      date = Time.local(*datestr.scan(/\d+/))
    else
      date = Time.local(*datestr.scan(/\d+/))+(60*60*12)
    end
    
    if doc.at('//meta[@content="video"]')
      video_url = doc.at('//meta[@property="og:video:secure_url"]').attribute('content').value
      @downloader.save_media(:video, video_url, @article_url, date, @member_id, @event_id, tmp)
    else
      image_url = doc.at('//meta[@property="og:image"]').attribute('content').value
      @downloader.save_media(:image, image_url, @article_url, date, @member_id, @event_id, tmp)
    end
  end
end
