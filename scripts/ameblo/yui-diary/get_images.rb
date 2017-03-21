#!/usr/bin/env ruby

# change working directory and require my_module
Dir.chdir(File.dirname(File.expand_path(__FILE__)))
require '../ameblo'
require '../../sqlite3'

# variables
$app_dir = '/home/ogura/rails/yuikaori/'
$media_dir = "#{$app_dir}app/assets/images/"
amebaID = 'ogura-yui'
# amebaIDをそのままディレクトリ名に使用するなら
# dir_name = "ameblo/#{amebaID}/"
dir_name = 'ameblo/yui-teatime/'
opt = {
  :depth_limit => 1,
  :delay => 2,
}

# crawl
client = SQL_Client.new
removed_addresses = client.removed_addresses
ameblo = Ameblo.new(amebaID, dir_name, removed_addresses)
ameblo.crawl(type: ARGV[0], opt: opt)

# add to database
client.insert_into("pictures", dir_name, 2)
client.close
