# frozen_string_literal: true

require 'rails_helper'

RSpec.describe LibPtgBox::ProductFamily do
  subject(:product_family) { described_class.new(sub_folder) }

  let(:sub_folder) { object_double(LibPtgBox::Unmarshaller::SubFolder.new(sub_box_folder), 'sub_folder') }
  let(:sub_box_folder) { instance_double(Box::Folder, 'sub_box_folder', name: 'Product_Family') }

  before do
    allow(sub_folder).to receive(:name).and_return(sub_box_folder.name)
  end

  describe '#name' do
    subject { product_family.name }

    it { is_expected.to eq(sub_box_folder.name) }
  end

  describe '#products' do
    subject { product_family.products }

    let(:kbart_folder) { instance_double(LibPtgBox::Unmarshaller::KbartFolder, 'kbart_folder') }
    let(:kbart_file) { object_double(LibPtgBox::Unmarshaller::KbartFile.new(kbart_box_file), 'kbart_box_file') }
    let(:kbart_box_file) { instance_double(Box::File, 'kbart_box_file', name: 'Product_0000_0000-00-00.csv') }
    let(:product) { 'product' }

    before do
      allow(sub_folder).to receive(:kbart_folder).and_return(kbart_folder)
      allow(kbart_folder).to receive(:kbart_files).and_return([kbart_file])
      allow(kbart_file).to receive(:name).and_return(kbart_box_file.name)
      allow(LibPtgBox::Product).to receive(:new).with(product_family, kbart_file).and_return(product)
    end

    it { is_expected.to contain_exactly(product) }
  end

  describe '#catalog' do
    subject { product_family.catalog }

    let(:marc_folder) { object_double(LibPtgBox::Unmarshaller::MarcFolder.new(marc_box_folder), 'marc_folder') }
    let(:marc_box_folder) { instance_double(Box::Folder, 'marc_box_folder', name: 'name') }
    let(:product_marc_file) { object_double(LibPtgBox::Unmarshaller::MarcFile.new(product_box_file), 'product_marc_file') }
    let(:product_box_file) { instance_double(Box::File, 'product_box_file', name: 'Product_Year.xml') }
    let(:complete_marc_file) { object_double(LibPtgBox::Unmarshaller::MarcFile.new(complete_box_file), 'complete_marc_file') }
    let(:complete_box_file) { instance_double(Box::File, 'complete_box_file', name: 'Product_Complete.xml', content: content) }
    let(:content) { '' }
    let(:catalog) { 'catalog' }

    before do
      allow(sub_folder).to receive(:cataloging_marc_folder).and_return(marc_folder)
      allow(marc_folder).to receive(:marc_files).and_return([product_marc_file, complete_marc_file])
      allow(product_marc_file).to receive(:name).and_return(product_box_file.name)
      allow(complete_marc_file).to receive(:name).and_return(complete_box_file.name)
      allow(complete_marc_file).to receive(:content).and_return(complete_box_file.content)
      allow(LibPtgBox::Catalog).to receive(:new).with(product_family, complete_marc_file).and_return(catalog)
    end

    it { is_expected.to eq(catalog) }
  end
end
