# frozen_string_literal: true

require 'rails_helper'

RSpec.describe LibPtgBox::Collection do
  subject(:collection) { described_class.new(sub_folder) }

  let(:sub_folder) { object_double(LibPtgBox::Unmarshaller::SubFolder.new(sub_ftp_folder), 'sub_folder') }
  let(:sub_ftp_folder) { instance_double(Ftp::Folder, 'sub_ftp_folder', name: 'Collection Metadata') }

  before do
    allow(sub_folder).to receive(:name).and_return(sub_ftp_folder.name)
  end

  describe '#name' do
    subject { collection.name }

    it { is_expected.to eq(/(^.+)(\sMetadata$)/i.match(sub_folder.name)[1]) }
  end

  describe '#selections' do
    subject { collection.selections }

    let(:kbart_folder) { instance_double(LibPtgBox::Unmarshaller::KbartFolder, 'kbart_folder') }
    let(:kbart_file) { object_double(LibPtgBox::Unmarshaller::KbartFile.new(kbart_ftp_file), 'kbart_ftp_file') }
    let(:kbart_ftp_file) { instance_double(Ftp::File, 'kbart_ftp_file', name: 'Selection_1999_1970-01-01.csv') }
    let(:selection) { 'selection' }

    before do
      allow(sub_folder).to receive(:kbart_folder).and_return(kbart_folder)
      allow(kbart_folder).to receive(:kbart_files).and_return([kbart_file])
      allow(kbart_file).to receive(:name).and_return(kbart_ftp_file.name)
      allow(LibPtgBox::Selection).to receive(:new).with(collection, kbart_file).and_return(selection)
    end

    it { is_expected.to contain_exactly(selection) }
  end

  describe '#upload_marc_file' do
    subject { collection.upload_marc_file(filename) }

    let(:filename) { instance_double(String, 'filename') }
    let(:marc_folder) { object_double(LibPtgBox::Unmarshaller::MarcFolder.new(marc_ftp_folder), 'marc_folder') }
    let(:marc_ftp_folder) { instance_double(Ftp::Folder, 'marc_ftp_folder', upload: 'upload') }

    before do
      allow(sub_folder).to receive(:upload_folder).and_return(marc_folder)
      allow(marc_folder).to receive(:upload).with(filename)
    end

    it do
      collection.upload_marc_file(filename)
      expect(marc_folder).to have_received(:upload).with(filename)
    end
  end

  describe '#marc' do
    subject { collection.marc(doi) }

    let(:doi) { 'doi' }
    let(:marcs) { [] }

    before { allow(collection).to receive(:marcs).and_return(marcs) }

    it { is_expected.to be_nil }

    context 'when marc' do
      let(:marcs) { [marc] }
      let(:marc) { instance_double(LibPtgBox::Unmarshaller::Marc, 'marc', doi: marc_doi) }
      let(:marc_doi) { 'marc' }

      it { is_expected.to be_nil }

      context 'when marc with doi' do # rubocop:disable RSpec/NestedGroups
        let(:marc_doi) { 'doi' }

        it { is_expected.to be marc }
      end
    end
  end

  describe '#marcs' do
    subject { collection.marcs }

    let(:marc_folder) { object_double(LibPtgBox::Unmarshaller::MarcFolder.new(marc_ftp_folder), 'marc_folder') }
    let(:marc_ftp_folder) { instance_double(Ftp::Folder, 'marc_ftp_folder', name: 'name') }
    let(:collection_marc_file) { object_double(LibPtgBox::Unmarshaller::MarcFile.new(collection_ftp_file), 'collection_marc_file') }
    let(:collection_ftp_file) { instance_double(Ftp::File, 'collection_ftp_file', name: 'Collection_Year.xml') }
    let(:complete_marc_file) { object_double(LibPtgBox::Unmarshaller::MarcFile.new(complete_ftp_file), 'complete_marc_file', marcs: marcs) }
    let(:complete_ftp_file) { instance_double(Ftp::File, 'complete_ftp_file', name: 'Collection_Complete.xml') }
    let(:marcs) { [] }
    let(:marc) { instance_double(LibPtgBox::Unmarshaller::Marc, 'marc', doi: marc_doi) }
    let(:marc_doi) { 'marc' }

    before do
      allow(sub_folder).to receive(:marc_folder).and_return(marc_folder)
      allow(marc_folder).to receive(:marc_files).and_return([collection_marc_file, complete_marc_file])
      allow(collection_marc_file).to receive(:name).and_return(collection_ftp_file.name)
      allow(complete_marc_file).to receive(:name).and_return(complete_ftp_file.name)
    end

    it { is_expected.to be_empty }

    context 'when marc' do
      let(:marcs) { [marc] }

      it { is_expected.to contain_exactly(marc) }
    end
  end

  describe '#catalog' do
    subject { collection.catalog }

    let(:marc_folder) { object_double(LibPtgBox::Unmarshaller::MarcFolder.new(marc_ftp_folder), 'marc_folder') }
    let(:marc_ftp_folder) { instance_double(Ftp::Folder, 'marc_ftp_folder', name: 'name') }
    let(:catalog) { 'catalog' }

    before do
      allow(sub_folder).to receive(:cataloging_marc_folder).and_return(marc_folder)
      allow(LibPtgBox::Catalog).to receive(:new).with(collection, marc_folder).and_return(catalog)
    end

    it { is_expected.to eq(catalog) }
  end
end
