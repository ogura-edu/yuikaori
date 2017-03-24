#!/usr/bin/env ruby

# change working directory and require my_module
Dir.chdir(File.dirname(File.expand_path(__FILE__)))
require './ameblo'
require '../sqlite3'

# variables
$app_dir = '/home/ogura/rails/yuikaori/'
$media_dir = "#{$app_dir}app/assets/images/"
$sqlclient = SQL_Client.new
opt = {
  :depth_limit => 1,
  :delay => 2,
}
## ARGV[0] ... amebaID
## ARGV[1] ... directory path from $media_dir
## ARGV[2] ... member_id
## ARGV[3] ... type(all or recent)

# crawl
removed_addresses = $sqlclient.removed_addresses
ameblo = Ameblo.new(ARGV[0], ARGV[1], removed_addresses)
ameblo.crawl(member_id: ARGV[2], type: ARGV[3], opt: opt)

$sqlclient.close
