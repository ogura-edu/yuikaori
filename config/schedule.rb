# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :output, "/path/to/my/cron_log.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

# Learn more: http://github.com/javan/whenever

set :output, 'log/crontab.log'
set :environment, :development

every '0 0 * * *' do
  script '/home/ogura/rails/yuikaori/script/ameblo/get_images.rb ogurayui-0815 ameba/yui-teatime 2 recent'
  script '/home/ogura/rails/yuikaori/script/ameblo/get_images.rb ishiharakaori-0806 ameba/kaori-mahalo 3 recent'
  script '/home/ogura/rails/yuikaori/script/instagram/get_media.rb recent'
  script '/home/ogura/rails/yuikaori/script/twitter/get_media.rb recent'
end
