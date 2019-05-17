# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CronScheduler do
  describe '#run' do
    let(:rufus) { instance_double(Rufus::Scheduler) }

    before do
      allow(Rufus::Scheduler).to receive(:new).and_return(rufus)
      allow(rufus).to receive(:cron)
      allow(rufus).to receive(:join)
    end

    it do # rubocop:disable RSpec/MultipleExpectations
      expect(described_class.run).to be_nil
      expect(rufus).to have_received(:cron)
      expect(rufus).to have_received(:join)
    end
  end
end
