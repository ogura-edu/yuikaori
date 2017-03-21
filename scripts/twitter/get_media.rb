#!/usr/bin/env ruby

Dir.chdir(File.dirname(File.expand_path(__FILE__)))
require './twitter'
require '../sqlite3'

# variables
screen_name = "YUIKAORI_STAFF"
options = {count: 50, include_rts: true, tweet_mode: "extended"}
$app_dir = '/home/ogura/rails/yuikaori/'
$media_dir = "#{$app_dir}app/assets/images/"
$image_dir = "twitter/images/"
$video_dir = "twitter/videos/"

sqlclient = SQL_Client.new
removed_addresses = sqlclient.removed_addresses
client = MyTwitterClient.new(type: :admin, removed_addresses: removed_addresses)

case ARGV[0]
when 'all'
  client.get_all_media(screen_name, options)
when 'recent'
  client.get_recent_media(screen_name, options)
else
  puts 'invalid type. please retry.'
  raise ArgumentError
end

sqlclient.insert_into("pictures", $image_dir, 1)
sqlclient.insert_into("videos", $video_dir, 1)
sqlclient.close
