# frozen_string_literal: true

require 'rufus-scheduler'

# Let's use the rufus-scheduler singleton
scheduler = Rufus::Scheduler.singleton

# Hourly
scheduler.every '1h' do
  Rails.logger.info "Hourly #{Time.now}"
  Rails.logger.flush
end

# Daily at 4:30 AM
# scheduler.cron '30 4 * * *' do
scheduler.cron '18 * * * *' do
  Rails.logger.info "Daily #{Time.now}"
  Rails.logger.flush
end
