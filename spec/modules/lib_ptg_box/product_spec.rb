# frozen_string_literal: true

require 'rails_helper'

RSpec.describe LibPtgBox::Product do
  subject(:product) { described_class.new(product_family, kbart_file) }

  let(:product_family) { instance_double(LibPtgBox::ProductFamily, 'product_family') }
  let(:kbart_file) { object_double(LibPtgBox::Unmarshaller::KbartFile.new(kbart_box_file), 'kbart_file') }
  let(:kbart_box_file) { instance_double(Box::File, 'kbart_box_file', name: kbart_file_name) }
  let(:kbart_file_name) { 'Prefix_1970_Suffix_1999-01-01.csv' }

  before { allow(kbart_file).to receive(:name).and_return(kbart_box_file.name) }

  it { expect(selection.name).to eq('Prefix_1970_Suffix') }
  it { expect(selection.year).to eq(1970) }
  it { expect(selection.updated).to eq(Date.parse('1999-01-01')) }

  describe '#works' do
    subject { product.works }

    let(:kbart) { 'kbart' }
    let(:work) { 'work' }

    before do
      allow(kbart_file).to receive(:kbarts).and_return([kbart])
      allow(LibPtgBox::Work).to receive(:new).with(product, kbart).and_return(work)
    end

    it { is_expected.to contain_exactly(work) }
  end
end
