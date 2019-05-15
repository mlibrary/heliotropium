# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Kbart::Filename do
  subject { described_class.new(filename) }

  let(:filename) { '' }

  it { is_expected.not_to be_nil }
end
