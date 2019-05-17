# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ApplicationCable::Connection do
  subject { described_class.new(server, env) }

  let(:server) { instance_double(ActionCable::Server::Base, 'server', worker_pool: 'worker_pool', logger: 'logger', config: config, event_loop: 'event_loop') }
  let(:config) { instance_double(ActionCable::Server::Configuration, 'config', log_tags: []) }
  let(:env) { instance_double(Hash, 'env') }

  before do
    allow(env).to receive(:[]).with('HTTP_CONNECTION').and_return('HTTP_CONNECTION')
    allow(env).to receive(:[]).with('HTTP_UPGRADE').and_return('HTTP_UPGRADE')
    allow(env).to receive(:[]).with('REQUEST_METHOD').and_return('REQUEST_METHOD')
  end

  it { is_expected.not_to be_nil }
end
