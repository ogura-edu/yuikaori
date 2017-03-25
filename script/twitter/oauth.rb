require 'oauth'
require 'json'

File.open("./application_data") do |file|
  lines = file.readlines
  $api_key = lines[2].gsub(/.*: /, "").gsub("\n", "")
  $api_secret = lines[3].gsub(/.*: /, "").gsub("\n", "")
end

$consumer = OAuth::Consumer.new($api_key, $api_secret, :site => "https://api.twitter.com/")

class User
  def initialize()
    request_token = $consumer.get_request_token
    authorize_url = request_token.authorize_url
    authenticate_url = authorize_url.gsub("authorize", "authenticate")

    puts "please access this URL:\n"+authorize_url
    puts "if you have authenticated already, please access this URL:\n"+authenticate_url
    pin = gets.chomp

    access_token = request_token.get_access_token(oauth_verifier: pin)
    @access_token = access_token.token
    @access_token_secret = access_token.secret
  end

  def config(client)
    client.consumer_key = $api_key
    client.consumer_secret = $api_secret
    client.access_token = @access_token
    client.access_token_secret = @access_token_secret
  end
end
