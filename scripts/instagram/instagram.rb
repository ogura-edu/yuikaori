require 'capybara'
require 'capybara/dsl'
require 'selenium-webdriver'
require 'open-uri'
require 'nokogiri'

Capybara.current_driver = :selenium
Capybara.default_max_wait_time = 20

module Instagram
  class << self
    def read_urls(filename)
      urls = []
      open(filename) do |file|
        file.each do |line|
          urls << line.strip
        end
      end
      return urls
    end
    
    def get_media(filename)
      read_urls(filename).each do |url|
        doc = Nokogiri::HTML.parse(open(url+"?hl=ja"))
        
        date = Time.new
        datestr = doc.at('meta[@property="og:title"]').attribute('content').value
        if datestr.include?('午前')
          date = Time.local(*datestr.scan(/\d+/))
        else
          date = Time.local(*datestr.scan(/\d+/))+(60*60*12)
        end
        
        if doc.at('//meta[@content="video"]')
          mp4_url = doc.at('//meta[@property="og:video:secure_url"]').attribute('content').value
          save_video(mp4_url, date)
        else
          save_image(url, date)
        end
      end
    end
    
    def save_video(url,date)
      basename = File.basename(url)
      filepath = "#{$media_dir}#{$video_dir}#{basename}"
      if File.exist?(filepath)
        puts "#{basename} has already been saved"
      else
        puts "download #{basename} ..."
        open(filepath, "w") do |output|
          open(url) do |data|
            output.write(data.read)
          end
        end
        File.utime(date, date, filepath)
      end
    end
    
    def save_image(url,date)
      basename = File.basename(url)
      filepath = "#{$media_dir}#{$image_dir}#{basename}.jpg"
      if File.exist?(filepath)
        puts "#{basename}.jpg has already been saved"
      else
        puts "download #{basename}.jpg"
        open(filepath, "w") do |output|
          open("#{url}media/?size=l") do |data|
            output.write(data.read)
          end
        end
        File.utime(date, date, filepath)
      end
    end
  end
  
  class Crawler
    include Capybara::DSL
    
    def initialize(url)
      ::Capybara.app_host = url
    end
    
    def login
      visit('/accounts/login/')
      page.fill_in 'username', :with => 'jas_yuikaori'
      page.fill_in 'password', :with => 'darkarmed'
      click_button 'Log in'
    end
    
    def load_all_posts
      # 仕様によりPCのアカウントページからは240枚しか読み込めない。
      # タイムラインは無限に読み込むようなので、一度に全ての投稿を得たい時はそっちのがいいかも。
      click_link "Load more"
      y_offset = 0
      loop do
        page.execute_script("window.scrollBy(0,2000);")
        sleep(3)
        if y_offset == page.evaluate_script("window.pageYOffset;")
          break;
        else
          y_offset = page.evaluate_script("window.pageYOffset;")
        end
      end
    end
    
    def check_post(filename)
      open(filename, "w") do |file|
        all(:xpath, '//a[@class="_8mlbc _vbtk2 _t5r8b"]').each do |result|
          file.puts result[:href].gsub(/\?.*$/, "")
        end
      end
    end
  end
end
