# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ApplicationCable::Channel do
  subject { described_class.new(connection, identifier) }

  let(:connection) { instance_double(ApplicationCable::Connection, 'connection', identifiers: []) }
  let(:identifier) { instance_double(String, 'identifier') }

  it { is_expected.not_to be_nil }
end
