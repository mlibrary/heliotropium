# frozen_string_literal: true

require 'rails_helper'

RSpec.describe LibPtgBox::Unmarshaller::Marc do
  subject { described_class.new(entry) }

  let(:entry) { instance_double(String, 'entry') }

  it { is_expected.not_to be_nil }
end
