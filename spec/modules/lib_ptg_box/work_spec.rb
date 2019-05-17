# frozen_string_literal: true

require 'rails_helper'

RSpec.describe LibPtgBox::Work do
  subject { described_class.new(product, kbart) }

  let(:product) { instance_double(LibPtgBox::Product, 'product') }
  let(:kbart) { instance_double(LibPtgBox::Unmarshaller::Kbart, 'kbart', doi: 'doi') }

  it { is_expected.not_to be_nil }
end
