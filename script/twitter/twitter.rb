require 'twitter'
require 'json'
require 'open-uri'
require './oauth'

class MyTwitterClient < Twitter::REST::Client
  
  def initialize(type:)
    super
    @removed_addresses = $sqlclient.removed_addresses
    case type
    when :admin
      self.consumer_key = 
      self.consumer_secret = 
      self.access_token = 
      self.access_token_secret = 
    when :user
      # 適当に書いてるのでエラーでる可能性高い
      # 要検証
      user = User.new
      user.config(self)
    end
  end
  
  # get all tweet(up to 3,200)
  def collect_with_max_id(collection=[], max_id=nil, &block)
    response = yield(max_id)
    collection << response
    response.empty? ? collection.flatten : collect_with_max_id(collection, response.last.id - 1, &block)
  end
  
  def get_all_tweets(screen_name, options)
    tweetary = []
    collect_with_max_id do |max_id|
      options[:max_id] = max_id unless max_id.nil?
      user_timeline(screen_name, options).each do |tweet|
        tweetary << tweet
      end
    end
    return tweetary
  end
  
  def get_many_tweets(screen_name, options, tweet_num)
    tweetary = []
    collect_with_max_id do |max_id|
      break if tweetary.size >= tweet_num
      options[:max_id] = max_id unless max_id.nil?
      user_timeline(screen_name, options).each do |tweet|
        tweetary << tweet
      end
    end
    return tweetary[0, tweet_num]
  end
  
  def save_result(str)
    File.open("result.json", "a") do |file|
      file.puts str
    end
  end
  
  def save_video(array, date, member_id, type)
    url = array.select{|item| item[:bitrate]}.max_by{|item| item[:bitrate]}[:url]
    basename = File.basename(url)
    filepath = "#{$media_dir}#{$video_dir}#{basename}"
    date = Time.parse(date)
    if File.exist?(filepath)
      puts "#{basename} has already been saved"
    elsif @removed_addresses.include?("#{$video_dir}#{basename}")
      puts "#{basename} has already been deleted"
    else
      puts "download #{basename}"
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
      end
    end
  end
  
  def save_image(url, date, member_id, type)
    basename = File.basename(url)
    filepath = "#{$media_dir}#{$image_dir}#{basename}"
    date = Time.parse(date)
    if File.exist?(filepath)
      puts "#{basename} has already been saved"
    elsif @removed_addresses.include?("#{$video_dir}#{basename}")
      puts "#{basename} has already been deleted"
    else
      puts "download #{basename}"
      open(filepath, "w") do |output|
        open(url) do |data|
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
  
  def get_media_url(hash, member_id, type)
    date = hash[:created_at]
    hash[:extended_entities][:media].each do |media|
      if media[:video_info]
        save_video(media[:video_info][:variants], date, member_id, type)
      else
        save_image(media[:media_url_https], date, member_id, type)
      end
    end
    puts "saved madia successfully"
  end
  
  def get_media(tweet, member_id, type)
    hash = tweet.attrs
    begin
      if hash[:is_quote_status]
        get_media_url(hash[:quoted_status], member_id, type)
      elsif hash[:retweeted_status]
        get_media_url(hash[:retweeted_status], member_id, type)
      else
        get_media_url(hash, member_id, type)
      end
    rescue
      puts "no media in tweetID:#{hash[:id_str]}"
    end
  end 
  
  def get_all_media(screen_name, options)
    get_all_tweets(screen_name, options).each do |tweet|
      get_media(tweet, 1, :auto)
    end
  end
  
  def get_recent_media(screen_name, options)
    user_timeline(screen_name, options).each do |tweet|
      get_media(tweet, 1, :auto)
    end
  end
  
  def manually_get_media(screen_name, options, add_opt)
    case add_opt[:type]
    when "date"
      puts '工事中！'
    when "number"
      get_many_tweets(screen_name, options, add_opt[:number]).each do |tweet|
        get_media(tweet, add_opt[:member_id], :manually)
      end
    end
  end
end