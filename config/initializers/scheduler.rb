# frozen_string_literal: true

require 'rufus-scheduler'

# Do not schedule when Rails is run from its console, for a test/spec, or from a Rake task
# return if defined?(Rails::Console) || Rails.env.test? || File.split($0).last == 'rake'
# Do not schedule unless Rails is run in production mode.
return unless Rails.env.production? && Settings.scheduler.enabled

Rails.logger.info "Schedule Task #{Time.now}"

# Let's use the rufus-scheduler singleton
scheduler = Rufus::Scheduler.singleton

# Heartbeat - do something every minute
# scheduler.every '1m' do
#   NotifierMailer.administrators("Hello World!").deliver_now
#   Rails.logger.info "Heartbeat #{Time.now}"
#   Rails.logger.flush
# end

# Hourly - do something every hour
# scheduler.every '1h' do
#   NotifierMailer.administrators("Hourly").deliver_now
#   Rails.logger.info "Hourly #{Time.now}"
#   Rails.logger.flush
# end

# Daily - do something every day
# (see "man 5 crontab" in your terminal)
scheduler.cron '0 23 * * *' do
  # Rails.logger.info "Daily #{Time.now}"
  # Rails.logger.flush
  # NotifierMailer.administrators("Daily").deliver_now
  AssembleMarcFiles.run
end
