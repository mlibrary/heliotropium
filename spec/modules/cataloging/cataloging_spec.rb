# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Cataloging::Cataloging do
  subject { described_class.new(product) }

  let(:product) { instance_double(String) }

  it { is_expected.not_to be_nil }
end
