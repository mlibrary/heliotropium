# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Kbart::Kbart do
  subject { described_class.new(filename) }

  let(:filename) { instance_double(String) }

  it { is_expected.not_to be_nil }
end
