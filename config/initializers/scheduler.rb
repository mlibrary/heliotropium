# frozen_string_literal: true

require 'rufus-scheduler'

# Let's use the rufus-scheduler singleton
scheduler = Rufus::Scheduler.singleton

# Do not schedule when Rails is run from its console, for a test/spec, or from a Rake task
# return if defined?(Rails::Console) || Rails.env.test? || File.split($0).last == 'rake'
return unless Rails.env.production?

Rails.logger.info "Schedule Task #{Time.now}"

# Heartbeat - do something every minute
# scheduler.every '1m' do
#   NotifierMailer.administrators("Hello World!").deliver_now
#   Rails.logger.info "Heartbeat #{Time.now}"
#   Rails.logger.flush
# end

# Hourly - do something every hour
scheduler.every '1h' do
  NotifierMailer.administrators("Hourly").deliver_now
  Rails.logger.info "Hourly #{Time.now}"
  Rails.logger.flush
end

# Daily - do something every day, five minutes after midnight
# (see "man 5 crontab" in your terminal)
scheduler.cron '5 0 * * *' do
  NotifierMailer.administrators("Daily").deliver_now
  Rails.logger.info "Daily #{Time.now}"
  Rails.logger.flush
end
