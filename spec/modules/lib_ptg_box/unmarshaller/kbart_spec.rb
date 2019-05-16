# frozen_string_literal: true

require 'rails_helper'

RSpec.describe LibPtgBox::Unmarshaller::Kbart do
  subject { described_class.new(line) }

  let(:line) { instance_double(String, 'line') }

  before do
    allow(line).to receive(:force_encoding).with('UTF-16BE').and_return(line)
    allow(line).to receive(:encode).with('UTF-8').and_return(line)
  end

  it { is_expected.not_to be_nil }
end
