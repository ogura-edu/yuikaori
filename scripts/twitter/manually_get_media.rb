#!/usr/bin/env ruby

Dir.chdir(File.dirname(File.expand_path(__FILE__)))
require './twitter'
require '../sqlite3'

# variables
$app_dir = '/home/ogura/rails/yuikaori/'
$media_dir = "#{$app_dir}app/assets/images/"
$image_dir = "manually/twitter/images/"
$video_dir = "manually/twitter/videos/"
$sqlclient = SQL_Client.new

client = MyTwitterClient.new(type: :admin)
