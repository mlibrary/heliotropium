# frozen_string_literal: true

require 'rufus-scheduler'

# Let's use the rufus-scheduler singleton
scheduler = Rufus::Scheduler.singleton

# Do not schedule when Rails is run from its console, for a test/spec, or from a Rake task
return if defined?(Rails::Console) || Rails.env.test? || File.split($0).last == 'rake'

Rails.logger.info "Schedule Task #{Time.now} ..."

# Hourly - do something every hour
scheduler.every '1h' do
  Rails.logger.info "Hourly #{Time.now}"
  Rails.logger.flush
end

# Daily - do something every day, five minutes after midnight
# (see "man 5 crontab" in your terminal)
scheduler.cron '5 0 * * *' do
  Rails.logger.info "Daily #{Time.now}"
  Rails.logger.flush
end

Rails.logger.info "End Schedule Task #{Time.now}"
