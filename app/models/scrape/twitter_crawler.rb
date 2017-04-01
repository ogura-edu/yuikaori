class Scrape::TwitterCrawler < Twitter::REST::Client
  
  def initialize(user_type:)
    super
    case user_type
    when :admin
      self.consumer_key = Settings.twitter.consumer_key
      self.consumer_secret = Settings.twitter.consumer_secret
      self.access_token = Settings.twitter.access_token
      self.access_token_secret = Settings.twitter.access_token_secret
    when :user
      # いずれユーザに投稿させるときに必要になる
    end
  end
  
  def validate(screen_name)
    screen_name = screen_name.downcase
    raise ArgumentError, '追跡済みのIDは指定しないでください' if skip_IDs.include?(screen_name)
  end
  
  def crawl(screen_name:, member_id:, type: :recent)
    screen_name = screen_name.downcase
    @downloader = Scrape::Downloader.new("twitter/#{screen_name}/")
    options = {
      count: 200,
      include_rts: true,
      tweet_mode: 'extended'
    }
    
    case type
    when :all
      get_all_tweets(screen_name, options).each do |tweet|
        classify_tweet(tweet, member_id, 1, false)
      end
    when :recent
      user_timeline(screen_name, options).each do |tweet|
        classify_tweet(tweet, member_id, 1, false)
      end
    end
  end
  
  def manually_crawl(params:)
    screen_name = params[:screen_name].downcase
    @downloader = Scrape::Downloader.new("twitter/#{screen_name}/")
    options = {
      count: 200,
      include_rts: true,
      tweet_mode: 'extended'
    }
    
    case params[:type]
    when 'period'
      get_tweets_in_certain_period(screen_name, options, params[:since], params[:until]).each do |tweet|
        classify_tweet(tweet, params[:member_id], params[:event_id], true)
      end
    when 'number'
      get_many_tweets(screen_name, options, params[:number].to_i).each do |tweet|
        classify_tweet(tweet, params[:member_id], params[:event_id], true)
      end
    end
  end
  
  private
  
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
  
  def get_tweets_in_certain_period(screen_name, options, since, till)
    options[:from] = screen_name
    options[:since] = since
    options[:until] = till
    return search('', options)
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
  
  def classify_tweet(tweet, member_id, event_id, tmp)
    hash = tweet.attrs
    begin
      if hash[:is_quote_status]
        parse_tweet(hash[:quoted_status], member_id, event_id, tmp)
      elsif hash[:retweeted_status]
        parse_tweet(hash[:retweeted_status], member_id, event_id, tmp)
      else
        parse_tweet(hash, member_id, event_id, tmp)
      end
    rescue
      puts "no media in tweetID:#{hash[:id_str]}"
    end
  end 
  
  def parse_tweet(hash, member_id, event_id, tmp)
    date = Time.parse(hash[:created_at])
    tweet_url = "https://twitter.com/#{hash[:user][:screen_name]}/status/#{hash[:id_str]}"
    
    hash[:extended_entities][:media].each do |media|
      if media[:video_info]
        url_list = media[:video_info][:variants].select{|item| item[:bitrate]}
        video_url = url_list.max_by{|item| item[:bitrate]}[:url]
        @downloader.save_media(:video, video_url, tweet_url, date, member_id, event_id, tmp)
      else
        image_url = media[:media_url_https]
        @downloader.save_media(:image, image_url, tweet_url, date, member_id, event_id, tmp)
      end
    end
    puts "saved madia successfully"
  end
  
  def skip_IDs
    Settings.twitter.regular_crawl.map{|obj| obj.ID}
  end
end
