class Scrape::InstagramCrawler
  include Capybara::DSL
  
  def initialize(url)
    ::Capybara.current_driver = :poltergeist
    ::Capybara.javascript_driver = :poltergeist
    ::Capybara.default_max_wait_time = 20
    ::Capybara.app_host = 'https://www.instagram.com/'
    ::Capybara.register_driver :poltergeist do |app|
      ::Capybara::Poltergeist::Driver.new(app, inspector: true, js_errors: false)
    end
    case url
    when %r{https://www.instagram.com/p/.*?/$}
      open(url) do |source|
        @instaID = source.read.match(/\(@(.*?)\)/)[1]
      end
    when %r{https://www.instagram.com/(.*?)/$}
      @instaID = $1
    else
      raise ArgumentError, '無効なアドレスです'
    end
    @downloader = Scrape::Downloader.new("instagram/#{@instaID}/")
  end
  
  def validate
    raise ArgumentError, '追跡済みのIDは指定しないでください' if skip_IDs.include?(@instaID)
  end
  
  def crawl(member_id:, type: :recent)
    login
    visit(@instaID)
    case type
    when :all
      load_all_posts
      check_post(member_id)
    when :recent
      check_post(member_id)
    end
  end
  
  def manually_crawl(params:)
    raise ArgumentError, '記事URLを指定してください' unless params[:post].match(%r{https://www.instagram.com/p/.*?/$})
    parse_post(params[:post], params[:member_id], params[:event_id], true)
    page.current_window.close
  end
  
  private
  
  def login
    visit('/accounts/login/')
    page.fill_in 'username', with: Settings.instagram.username
    page.fill_in 'password', with: Settings.instagram.password
    click_button 'ログイン'
  end
  
  def load_all_posts
    click_link "さらに表示"
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
  
  def check_post(member_id)
    all(:xpath, '//a[@class="_8mlbc _vbtk2 _t5r8b"]').each do |result|
      post_url = result[:href].gsub(/\?.*$/, "")
      parse_post(post_url, member_id, 1, false)
    end
  end
  
  def skip_IDs
    Settings.instagram.regular_crawl.map{|obj| obj.ID}
  end
  
  def parse_post(url, member_id, event_id, tmp)
    doc = Nokogiri::HTML.parse(open(url+"?hl=ja"))
    
    date = Time.new
    datestr = doc.at('meta[@property="og:title"]').attribute('content').value
    if datestr.include?('午前')
      date = Time.local(*datestr.scan(/\d+/))
    else
      date = Time.local(*datestr.scan(/\d+/))+(60*60*12)
    end
    
    if doc.at('//meta[@content="video"]')
      video_url = doc.at('//meta[@property="og:video:secure_url"]').attribute('content').value
      @downloader.save_media(:video, video_url, url, date, member_id, event_id, tmp)
    else
      image_url = doc.at('//meta[@property="og:image"]').attribute('content').value
      @downloader.save_media(:image, image_url, url, date, member_id, event_id, tmp)
    end
  end
end
