class Scrape::TwitterCrawler < Twitter::REST::Client
  attr_accessor :errors
  
  def initialize(params)
    super()
    case params[:user_type]
    when :admin
      self.consumer_key = ENV['TWITTER_CONSUMER_KEY']
      self.consumer_secret = ENV['TWITTER_CONSUMER_SECRET']
      self.access_token = ENV['TWITTER_ACCESS_TOKEN']
      self.access_token_secret = ENV['TWITTER_ACCESS_TOKEN_SECRET']
    when :user
      # いずれユーザに投稿させるときに必要になる
    end
    member_id = params[:member_id]
    event_id = params[:event_id]
    new_event = params[:event_attributes]
    tag_list = params[:tag_list]
    tmp = params[:tmp]
    @type = params[:type]
    case @type
    when 'auto'
      @screen_name = params[:screen_name].downcase
    when 'date'
      @screen_name = params[:screen_name].downcase
      @since = params[:since]
      @until = params[:until]
    when 'number'
      @screen_name = params[:screen_name].downcase
      @tweet_num = params[:number].to_i
    when 'tweet'
      @article_url = params[:tweet_url]
      @article_url.match %r{https://twitter.com/(.+?)/status/(\d+)$}
      @screen_name = $1.try(:downcase)
      # Twitter::Error::NotFoundを拾うためにrescue
      @tweet = status(Twitter::Tweet.new(id: $2), {tweet_mode: 'extended'}) rescue nil
    end
    @downloader = Scrape::Downloader.new("twitter/#{@screen_name}/", member_id, event_id, new_event, tag_list, tmp)
  end
  
  def validate
    case @type
    when 'date'
    when 'number'
    when 'tweet'
      if @screen_name.nil?
        @errors = '無効なURLです'
        return false
      elsif @tweet.nil?
        @errors = '存在しないツイートです'
        return false
      end
    end
    
    if !user?(@screen_name)
      @errors = '存在しないユーザです'
      return false
    elsif skip_IDs.include?(@screen_name)
      @errors = '追跡済みのユーザは指定しないでください'
      return false
    end
    
    true
  end
  
  def crawl(type: :recent)
    options = {
      count:       200,
      include_rts: true,
      tweet_mode:  'extended',
    }
    
    case type
    when :all
      get_all_tweets(options).each do |tweet|
        classify_tweet(tweet.attrs)
      end
    when :recent
      user_timeline(@screen_name, options).each do |tweet|
        classify_tweet(tweet.attrs)
      end
    end
  end
  
  def manually_crawl
    options = {
      count:       200,
      include_rts: true,
      tweet_mode:  'extended',
    }
    
    case @type
    when 'date'
      get_tweets_in_certain_date(options).each do |tweet|
        classify_tweet(tweet.attrs)
      end
    when 'number'
      get_many_tweets(options).each do |tweet|
        classify_tweet(tweet.attrs)
      end
    when 'tweet'
      parse_tweet(@tweet.attrs)
    end
  end
  
  private
  
  # get all tweet(up to 3,200)
  def collect_with_max_id(collection=[], max_id=nil, &block)
    response = yield(max_id)
    collection << response
    response.empty? ? collection.flatten : collect_with_max_id(collection, response.last.id - 1, &block)
  end
  
  def get_all_tweets(options)
    tweetary = []
    collect_with_max_id do |max_id|
      options[:max_id] = max_id unless max_id.nil?
      user_timeline(@screen_name, options).each do |tweet|
        tweetary << tweet
      end
    end
    tweetary
  end
  
  # limit: about 10 days ago
  def get_tweets_in_certain_date(options)
    options[:from] = @screen_name
    options[:since] = @since
    options[:until] = @until
    search('', options)
  end
  
  def get_many_tweets(options)
    tweetary = []
    collect_with_max_id do |max_id|
      break if tweetary.size >= @tweet_num
      options[:max_id] = max_id unless max_id.nil?
      user_timeline(@screen_name, options).each do |tweet|
        tweetary << tweet
      end
    end
    tweetary[0, @tweet_num]
  end
  
  def classify_tweet(tweet)
    begin
      if tweet[:is_quote_status]
        parse_tweet(tweet[:quoted_status])
      elsif tweet[:retweeted_status]
        parse_tweet(tweet[:retweeted_status])
      else
        parse_tweet(tweet)
      end
    rescue
      puts "no media in tweetID:#{tweet[:id_str]}"
    end
  end 
  
  def parse_tweet(tweet)
    date = Time.parse(tweet[:created_at])
    @article_url = "https://twitter.com/#{tweet[:user][:screen_name]}/status/#{tweet[:id_str]}"
    
    tweet[:extended_entities][:media].each do |media|
      if media[:video_info]
        url_list = media[:video_info][:variants].select{|item| item[:bitrate]}
        video_url = url_list.max_by{|item| item[:bitrate]}[:url]
        @downloader.save_media(:video, video_url, @article_url, date)
      else
        image_url = media[:media_url_https]
        @downloader.save_media(:image, image_url, @article_url, date)
      end
    end
    puts "saved madia successfully"
  end
  
  def skip_IDs
    Settings.twitter.regular_crawl.map{|obj| obj.ID}
  end
end
