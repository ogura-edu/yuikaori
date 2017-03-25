#!/usr/bin/env ruby

# change working directory and require my_module
Dir.chdir(File.dirname(File.expand_path(__FILE__)))
require './ameblo'
require '../sqlite3'

# variables
$app_dir = '/home/ogura/rails/yuikaori/'
$media_dir = "#{$app_dir}app/assets/images/"
$sqlclient = SQL_Client.new
## ARGV[0] ... article URL
## ARGV[1] ... member_id
amebaID = ARGV[0].gsub(%r{http://ameblo.jp/(.*?)/.*}, '\1')
dir_name = "manually/ameblo/#{amebaID}/"

# amebaIDにゆいかおりブログが指定されたらエラーを吐くように
if %w(ogura-yui ogurayui-0815 ishiharakaori ishiharakaori-0806).include?(amebaID)
  raise ArgumentError, 'ゆいかおりのブログは指定しないでください'
end

# make directory
unless Dir.exist?("#{$media_dir}#{dir_name}")
  Dir.mkdir("#{$media_dir}#{dir_name}")
  puts 'made a directory.'
end

removed_addresses = $sqlclient.removed_addresses
ameblo = Ameblo.new(amebaID, dir_name, removed_addresses)
ameblo.manually_crawl(article_url: ARGV[0], member_id: ARGV[1])

$sqlclient.close
