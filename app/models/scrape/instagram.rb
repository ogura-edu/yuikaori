require 'capybara'
require 'capybara/dsl'
require 'selenium-webdriver'
require 'open-uri'
require 'nokogiri'

Capybara.current_driver = :selenium
Capybara.default_max_wait_time = 20

module Scrape::Instagram
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
    
    def load_postdata_from(filename, removed_addresses)
      read_urls(filename).each do |url|
        get_media(url, removed_addresses, 2, type: :auto)
      end
    end

    def get_media(url, removed_addresses, member_id, type:)
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
        save_video(mp4_url, date, removed_addresses, member_id, type: type)
      else
        save_image(url, date, removed_addresses, member_id, type: type)
      end
    end
    
    def save_video(url, date, removed_addresses, member_id, type:)
      basename = File.basename(url)
      filepath = "#{$media_dir}#{$video_dir}#{basename}"
      if File.exist?(filepath)
        puts "#{basename} has already been saved"
      elsif removed_addresses.include?("#{$video_dir}#{basename}")
        puts "#{basename} has already been deleted"
      else
        puts "download #{basename} ..."
        open(filepath, "w") do |output|
          open(url) do |data|
            output.write(data.read)
          end
        end
        File.utime(date, date, filepath)
        
        # save to database
        case type
        when :auto
          $sqlclient.insert_into("videos", "#{$video_dir}#{basename}", member_id)
        when :manually
          $sqlclient.manually_insert("videos", "#{$video_dir}#{basename}", member_id)
        else
          puts 'please select correct type'
        end
      end
    end
    
    def save_image(url, date, removed_addresses, member_id, type:)
      basename = File.basename(url) + '.jpg'
      filepath = "#{$media_dir}#{$image_dir}#{basename}"
      if File.exist?(filepath)
        puts "#{basename} has already been saved"
      elsif removed_addresses.include?("#{$image_dir}#{basename}")
        puts "#{basename} has alredy been deleted"
      else
        puts "download #{basename}"
        open(filepath, "w") do |output|
          open("#{url}media/?size=l") do |data|
            output.write(data.read)
          end
        end
        File.utime(date, date, filepath)
        
        # save to database
        case type
        when :auto
          $sqlclient.insert_into("pictures", "#{$image_dir}#{basename}", member_id)
        when :manually
          $sqlclient.manually_insert("pictures", "#{$image_dir}#{basename}", member_id)
        end
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
