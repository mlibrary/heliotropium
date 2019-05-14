# frozen_string_literal: true

class CronScheduler
  def self.run
    scheduler = Rufus::Scheduler.new

    # Daily at 4:30 AM
    # scheduler.cron '30 4 * * *' do
    scheduler.cron '18 * * * *' do
      # AssembleMarcFiles.new.run
    end

    scheduler.join
  end
end
