# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ApplicationRecord do
  subject { abstract }

  let(:abstract) { object_double(described_class, 'abstract') }

  it { is_expected.not_to be_nil }
end
