# frozen_string_literal: true

require 'rails_helper'

RSpec.describe LibPtgBox::Product do
  subject { described_class.new(product_family, kbart_file) }

  let(:product_family) { instance_double(LibPtgBox::ProductFamily, 'product_family') }
  let(:kbart_file) { object_double(LibPtgBox::Unmarshaller::KbartFile.new(box_file), 'kbart_file') }
  let(:box_file) { instance_double(Box::File, 'box_file', name: 'Product_0000_0000-00-00.csv') }

  before do
    allow(kbart_file).to receive(:name).and_return(box_file.name)
  end

  it { is_expected.not_to be_nil }
end
