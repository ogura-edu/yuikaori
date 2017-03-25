#!/usr/bin/env ruby

Dir.chdir(File.dirname(File.expand_path(__FILE__)))
require './instagram'
require '../sqlite3'

# variables
$insta_host = 'https://www.instagram.com/'
$app_dir = '/home/ogura/rails/yuikaori/'
$media_dir = "#{$app_dir}app/assets/images/"
$image_dir = "manually/instagram/images/"
$video_dir = "manually/instagram/videos/"
$sqlclient = SQL_Client.new
url = ""

# check ARGV
# ARGV[0] ... URL or articleID
# ARGV[1] ... member_id
if ARGV[0] =~ %r{^https://www.instagram.com/p/.*?/$}
  url = ARGV[0]
elsif !(ARGV[0] =~ %r{/})
  url = "#{$insta_host}p/#{ARGV[0]}"
else
  raise ArgumentError
end

removed_addresses = $sqlclient.removed_addresses
Instagram.get_media(url, removed_addresses, ARGV[1], type: :manually)
$sqlclient.close
