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

job_type :capybara, 'export DISPLAY=:0 && export PATH=$PATH:/usr/local/bin && cd :path && :environment_variable=:environment bundle exec script/:task :output'

every '0 0 * * *' do
  capybara 'instagram/get_media.rb recent'
end

every '5 0 * * *' do
  script 'ameblo/get_images.rb ishiharakaori-0806 ameblo/kaori-mahalo/ 3 recent'
end

every '10 0 * * *' do
  script 'ameblo/get_images.rb ogurayui-0815 ameblo/yui-teatime/ 2 recent'
end

every '15 0 * * *' do
  script 'twitter/get_media.rb recent'
end
