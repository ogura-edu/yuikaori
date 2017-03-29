# coding: utf-8

require 'anemone'
require 'nokogiri'
require 'open-uri'

class Scrape::Ameblo
  def initialize(amebaID, dir_name)
    @amebaID = amebaID
    @dir_name = dir_name
    @host = "http://ameblo.jp/#{amebaID}/"
  end
  
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
  
  def save_image(url, member_id, event_id, type:)
    filename = File.basename(url)
    filepath = Rails.root.join("app/assets/images/#{@dir_name}#{filename}")
    datestr = url.gsub(/.*user_images\/(.*?)\//, '\1')
    dateary = [datestr.slice(0,4), datestr.slice(4,2), datestr.slice(6,2)]
    date = Time.local(*dateary)
    
    if File.exist?(filepath)
      puts "#{filename} has already been saved"
    elsif RemovedAddress.find_by_address("#{@dir_name}#{filename}")
      puts "#{filename} has already been deleted"
    else
      puts "download #{filename}"
      open(filepath, "w:#{open(url).to_s.encoding.to_s}") do |output|
        begin
          open(url) do |data|
            output.write(data.read)
          end
        rescue OpenURI::HTTPError
          puts "#{filename} was deleted from server"
        end
      end
      File.utime(date, date, filepath)
      
      # save to database
      case type
      when :auto
        begin
          Picture.create(
            member_id: member_id,
            event_id: 0,
            address: "#{@dir_name}#{filename}",
            date: date.strftime("%Y-%m-%d %H:%M:%S"),
            created_at: Time.now.strftime("%Y-%m-%d %H:%M:%S"),
            updated_at: Time.now.strftime("%Y-%m-%d %H:%M:%S")
          )
        rescue
          puts 'already added'
        end
      when :manually
        begin
          Picture.create(
            member_id: member_id,
            event_id: event_id,
            address: "#{@dir_name}#{filename}",
            date: date.strftime("%Y-%m-%d %H:%M:%S"),
            created_at: Time.now.strftime("%Y-%m-%d %H:%M:%S"),
            updated_at: Time.now.strftime("%Y-%m-%d %H:%M:%S"),
            tmp: 't'
          )
        rescue
          puts 'already added'
        end
      end
    end
  end
  
  def single_crawl(url, opt, member_id)
    Anemone.crawl(url, opt) do |anemone|
      anemone.focus_crawl do |page|
        page.links.keep_if do |link|
          link.to_s.match(/#{@amebaID}\/entry-[\d]*\.html/)
        end
      end
      
      begin
        anemone.on_every_page do |page|
          puts "image on #{page.url} :"
          page.doc.xpath('//div[@class="articleText"]//a/img').each do |img|
            image_url = img.attribute('src').value.gsub(/t[\d]*_/, 'o').gsub(/\?.*$/, '')
            break if File.extname(image_url) == ".gif"
            save_image(image_url, member_id, type: :auto)
          end
        end
      rescue => ex
        puts ex
        puts 'please retry'
      end
    end
  end
  
  def crawl(member_id:, type:, opt:)
    case type
    when 'all'
      all_entrylist.each do |entrylist_url|
        single_crawl(entrylist_url, opt, member_id)
      end
    when 'recent'
      single_crawl("#{@host}entrylist.html", opt, member_id)
    else
      puts 'invalid type. please retry.'
    end
  end
  
  def manually_crawl(params)
    doc = Nokogiri::HTML.parse(open(params[:article_url]))
    doc.xpath('//div[@class="articleText" or  @class="subContentsInner"]//a/img').each do |img|
      image_url = img.attribute('src').value.gsub(/t[\d]*_/, 'o').gsub(/\?.*$/, '')
      break if File.extname(image_url) == '.gif'
      puts image_url
      save_image(image_url, params[:member_id], params[:event_id], type: :manually)
    end
  end
end
