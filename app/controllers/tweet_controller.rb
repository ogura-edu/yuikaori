class TweetController < ApplicationController
  before_action :twitter_client
  
  def twitter_client
    @client = Twitter::REST::Client.new do |config|
      config.consumer_key = "9JR8NiVlM2SJOhfjScUJ9HMUa"
      config.consumer_secret = "ZWtegYpGAUh83AQj3W3pEHGVMpLHTauI6xqefzkFlOkaFqyddb"
      config.access_token = "272968442-q9mxMzX0mNH39cwdT7XTZOMNT8xz4DzWkoSvt5ac"
      config.access_token_secret = "cWggDJdKcqQUKmr5jmj6QxRxtXBPBKOq8G91JSt0Wby1z"
    end
  end
  
  def index
    redirect_back fallback_location: toppage_path, alert: '一般ユーザはは入れません' unless current_user.admin?
    @tweets = []
    @client.user_timeline("justice_vsbr", {count:200, include_rts:true}).each {|tweet|
      @tweets << tweet
    }
  end
end
