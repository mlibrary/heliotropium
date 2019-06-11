# frozen_string_literal: true

require 'rails_helper'

RSpec.describe LibPtgBox::Product do
  subject(:product) { described_class.new(collection, kbart_file) }

  let(:collection) { instance_double(LibPtgBox::Collection, 'collection') }
  let(:kbart_file) { object_double(LibPtgBox::Unmarshaller::KbartFile.new(kbart_box_file), 'kbart_file') }
  let(:kbart_box_file) { instance_double(Box::File, 'kbart_box_file', name: kbart_file_name) }
  let(:kbart_file_name) { 'Product_0000_0000-00-00.csv' }

  before { allow(kbart_file).to receive(:name).and_return(kbart_box_file.name) }

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

  describe '#year?' do
    subject { product.year? }

    it { is_expected.to be false }

    context 'with year' do
      let(:kbart_file_name) { "Product_#{format('%04d', Time.now.year)}_0000-00-00.csv" }

      it { is_expected.to be true }
    end
  end

  describe '#modified_today?' do
    subject { product.modified_today? }

    it { is_expected.to be false }

    context 'with today' do
      let(:today) { Time.now }
      let(:kbart_file_name) { "Product_0000_#{format('%04d', today.year)}-#{format('%02d', today.month)}-#{format('%02d', today.day)}.csv" }

      it { is_expected.to be true }
    end
  end

  describe 'modified_this_month?' do
    subject { product.modified_this_month? }

    it { is_expected.to be false }

    context 'with month' do
      let(:today) { Time.now }
      let(:kbart_file_name) { "Product_0000_#{format('%04d', today.year)}-#{format('%02d', today.month)}-00.csv" }

      it { is_expected.to be true }
    end
  end

  describe 'modified_this_year?' do
    subject { product.modified_this_year? }

    it { is_expected.to be false }

    context 'with year' do
      let(:today) { Time.now }
      let(:kbart_file_name) { "Product_0000_#{format('%04d', today.year)}-00-00.csv" }

      it { is_expected.to be true }
    end
  end
end
