require 'twitter'
require 'json'
require 'open-uri'
require './oauth'

class MyTwitterClient
  def initialize(type:, screen_name: nil)
    case type
    when :admin
      puts 'type admin'
      @client = Twitter::REST::Client.new do |config|
        config.consumer_key = "HICQLnFdWvpD390L7hw6Y3Phx"
        config.consumer_secret = "x02WyH82h76ETJlpWvFu7R9Nhhfgty6TuMBKp1ZXaENRNPx2Qc"
        config.access_token = "272968442-MnbnHokfqR9lyWS8pNm2JzhG426osPb777LYPDqm"
        config.access_token_secret = "MsVaeBYwqzP0uWiNyiBwnrxTTFQYwPThuqik8EzdtmHR0"
      end
    when :user
      user = User.new
      @client = Twitter::REST::Client.new do |c|
        user.config(c)
      end
    end
  end
  
  # get all tweet(up to 3,200)
  def collect_with_max_id(collection=[], max_id=nil, &block)
    response = yield(max_id)
    collection << response
    response.empty? ? collection.flatten : collect_with_max_id(collection, response.last.id - 1, &block)
  end
  
  def @client.get_all_tweets(screen_name, options)
    tweetary = []
    collect_with_max_id do |max_id|
      options[:max_id] = max_id unless max_id.nil?
      user_timeline(screen_name, options).each do |tweet|
        tweetary << tweet
      end
    end
    return tweetary
  end
  
  def save_result(str)
    File.open("result.json", "a") do |file|
      file.puts str
    end
  end
  
  def save_video(array, date)
    url = array.select{|item| item[:bitrate]}.max_by{|item| item[:bitrate]}[:url]
    basename = File.basename(url)
    filepath = "#{$media_dir}#{$video_dir}#{basename}"
    date = Time.parse(date)
    if File.exist?(filepath)
      puts "#{basename} has already been saved"
    else
      puts "download #{basename}"
      open(filepath, "w") do |output|
        open(url) do |data|
          output.write(data.read)
        end
      end
      File.utime(date, date, filepath)
    end
  end
  
  def save_image(url, date)
    basename = File.basename(url)
    filepath = "#{$media_dir}#{$image_dir}#{basename}"
    date = Time.parse(date)
    if File.exist?(filepath)
      puts "#{basename} has already been saved"
    else
      puts "download #{basename}"
      open(filepath, "w") do |output|
        open(url) do |data|
          output.write(data.read)
        end
      end
      File.utime(date, date, filepath)
    end
  end
  
  def get_media_url(hash)
    date = hash[:created_at]
    hash[:extended_entities][:media].each do |media|
      if media[:video_info]
        save_video(media[:video_info][:variants], date)
      else
        save_image(media[:media_url_https], date)
      end
    end
    puts "saved madia successfully"
  end
  
  def get_media(tweet)
    hash = tweet.attrs
    begin
      if hash[:is_quote_status]
        get_media_url(hash[:quoted_status])
      elsif hash[:retweeted_status]
        get_media_url(hash[:retweeted_status])
      else
        get_media_url(hash)
      end
    rescue
      puts "no media in tweetID:#{hash[:id_str]}"
    end
  end 
  
  def get_all_media(screen_name, options)
    @client.get_all_tweets(screen_name, options).each do |tweet|
      get_media(tweet)
    end
  end
  
  def get_recent_media(screen_name, options)
    @client.user_timeline(screen_name, options).each do |tweet|
      get_media(tweet)
    end
  end
end
