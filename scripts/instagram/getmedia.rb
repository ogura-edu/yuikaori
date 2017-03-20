#!/usr/bin/env ruby

Dir.chdir(File.dirname(File.expand_path(__FILE__)))
require './instagram'
require '../sqlite3'

# variables
$insta_host = 'https://www.instagram.com/'
$app_dir = '/home/ogura/rails/yuikaori/'
$media_dir = "#{$app_dir}app/assets/images/"
$image_dir = "instagram/images/"
$video_dir = "instagram/videos/"
recent_result = "recentposts"

# check recent posts
crawler = Instagram::Crawler.new($insta_host)
crawler.login
crawler.visit('/yui_ogura_official/')
case ARGV[0]
when 'all'
  # ただし最大240枚まで
  crawler.load_all_posts
  crawler.check_post(recent_result)
when 'recent'
  crawler.check_post(recent_result)
else
  puts 'invalid type. please retry.'
  raise ArgumentError
end

# get media from result_file
Instagram.get_media(recent_result)

# add media to database
client = SQL_Client.new
client.insert_into("pictures", $image_dir, 2)
client.insert_into("videos", $video_dir, 2)
client.close

# update allpostdata
all_result = Dir.glob("allpostdata*").first
timestr = Time.now.to_s
File.open("allpostdata_#{timestr}", "w") do |new_file|
  ary = []
  File.open(recent_result) do |file|
    file.each do |row|
      ary << row
    end
  end
  File.open(all_result) do |file|
    file.each do |row|
      ary << row
    end
  end
  ary.uniq.each do |row|
    new_file.puts row
  end
end
File.delete(all_result)
