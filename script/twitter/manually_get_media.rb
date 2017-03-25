#!/usr/bin/env ruby

Dir.chdir(File.dirname(File.expand_path(__FILE__)))
require 'json'
require './twitter'
require '../sqlite3'

# variables
$app_dir = '/home/ogura/rails/yuikaori/'
$media_dir = "#{$app_dir}app/assets/images/"
$image_dir = "manually/twitter/images/"
$video_dir = "manually/twitter/videos/"
$sqlclient = SQL_Client.new

# ARGV[0] ... screen_name
# ARGV[1] ... api_options(JSON形式, 必ずダブルクォートで)
# RT含むかどうかとかいろいろ
# ARGV[2] ... additional_options(JSON形式, 必ずダブルクォートで)
# type: ... "date", "number"
#   "date" -> いつからいつまでとかをハッシュで指定
#   "number" -> 取得ツイート数をハッシュで指定
# member_id: ... 0~2 必須
# 他にもタイプあるかも。追加できる。

screen_name = ARGV[0]
api_opt = { count: 200, include_rts: true, tweet_mode: "extended" }.merge(JSON.parse(ARGV[1], { symbolize_names: true }))
add_opt = JSON.parse(ARGV[2], { symbolize_names: true })

@client = MyTwitterClient.new(type: :admin)
@client.manually_get_media(screen_name, api_opt, add_opt)

$sqlclient.close
