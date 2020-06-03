# frozen_string_literal: true

require 'rails_helper'

RSpec.describe LibPtgBox::LibPtgBox do
  let(:collection_hash) { Settings.lib_ptg_box.collections.first }
  let(:sub_folder) { object_double(LibPtgBox::Unmarshaller::SubFolder.new(sub_ftp_folder), 'sub_folder', name: sub_ftp_folder.name) }
  let(:sub_ftp_folder) { instance_double(Ftp::Folder, 'sub_ftp_folder', name: collection_hash.folder) }
  let(:collection) { instance_double(LibPtgBox::Collection, 'collection', key: collection_hash.key, name: 'UMPEBC', catalog: catalog, selections: [selection]) }
  let(:catalog) { instance_double(LibPtgBox::Catalog, 'catalog', marc_folder: marc_folder) }
  let(:marc_folder) { object_double(LibPtgBox::Unmarshaller::MarcFolder.new(marc_ftp_folder), 'marc_folder', marc_files: marc_files, name: marc_ftp_folder.name) }
  let(:marc_ftp_folder) { instance_double(Ftp::Folder, 'marc_ftp_folder', name: 'folder') }
  let(:marc_files) { [] }
  let(:selection) {  instance_double(LibPtgBox::Selection, 'selection', name: 'name', year: 'year') }

  before do
    allow(LibPtgBox::Unmarshaller::RootFolder).to receive(:sub_folders).and_return([sub_folder])
    allow(LibPtgBox::Collection).to receive(:new).with(collection_hash, sub_folder).and_return(collection)
  end

  it '#initialize' do
    described_class.new
    expect(Dir.pwd).to eq(Rails.root.join('tmp', 'lib_ptg_box').to_s)
  end

  describe '#collections' do
    subject { described_class.new.collections }

    it { is_expected.to contain_exactly(collection) }
  end

  describe '#synchronize_marc_records' do
    subject(:synchronize_marc_records) { described_class.new.synchronize_marc_records(collection) }

    let(:marc_files) { [marc_file] }
    let(:marc_file) { object_double(LibPtgBox::Unmarshaller::MarcFile.new(marc_ftp_file), 'marc_file', name: marc_ftp_file.name, updated: marc_ftp_file.updated, content: marc_ftp_file.content) }
    let(:marc_ftp_file) { instance_double(Ftp::File, 'marc_ftp_file', name: '0000000000000.mrc', updated: updated, content: content) }
    let(:updated) { Date.parse('1970-01-01') }
    let(:content) { 'content' }
    let(:string_io) { instance_double(StringIO, 'string_io') }
    let(:reader) { instance_double(MARC::Reader, 'reader') }
    let(:record) { instance_double(MARC::Record, 'record') }
    let(:marc) { instance_double(LibPtgBox::Unmarshaller::Marc, 'marc', doi: 'doi') }

    before do
      allow(MARC::Reader).to receive(:new).with(string_io, external_encoding: "UTF-8", validate_encoding: true).and_return(reader)
      allow(StringIO).to receive(:new).with(content).and_return(string_io)
      allow(reader).to receive(:each).and_yield(record)
      allow(record).to receive(:to_marc).and_return('mrc')
      allow(LibPtgBox::Unmarshaller::Marc).to receive(:new).with(record).and_return(marc)
    end

    it 'new file' do
      expect(synchronize_marc_records).to contain_exactly("INFO: MARC Record updated in #{collection.key} > 0000000000000.mrc")
      expect(MarcRecord.count).to eq(1)
      marc_record = MarcRecord.first
      expect(marc_record.selected).to be true
      expect(marc_record.updated).to eq('1970-01-01 00:00:00.000000000 +0000')
      expect(marc_record.content).to eq('content')
      expect(marc_record.mrc).to eq('mrc')
      expect(marc_record.doi).to eq('doi')
      expect(marc_record.count).to eq(1)
      expect(marc_record.parsed).to be true
    end

    it 'logs orphan marc record' do
      marc_record = create(:marc_record, folder: collection.name)
      expect(MarcRecord.count).to eq(1)
      expect(synchronize_marc_records).to contain_exactly("WARNING: MARC FILE NOT FOUND #{marc_record.folder} > #{marc_record.file}", "INFO: MARC Record updated in #{collection.key} > 0000000000000.mrc")
      expect(MarcRecord.count).to eq(2)
    end

    context 'when new file is empty' do
      before { allow(reader).to receive(:each).and_return(nil) }

      it do
        expect(synchronize_marc_records).to contain_exactly("INFO: MARC Record updated in #{collection.key} > 0000000000000.mrc", "ERROR: NO MARC Record in #{collection.key} > 0000000000000.mrc record count = 0")
        expect(MarcRecord.count).to eq(1)
        marc_record = MarcRecord.first
        expect(marc_record.selected).to be true
        expect(marc_record.updated).to eq('1970-01-01 00:00:00.000000000 +0000')
        expect(marc_record.content).to eq('content')
        expect(marc_record.count).to eq(0)
        expect(marc_record.mrc).to be nil
        expect(marc_record.doi).to be nil
        expect(marc_record.parsed).to be false
      end
    end

    context 'when new file has multiple entries' do
      before { allow(reader).to receive(:each).and_yield(record).and_yield(record) }

      it do
        expect(synchronize_marc_records).to contain_exactly("INFO: MARC Record updated in #{collection.key} > 0000000000000.mrc", "WARNING: MULTIPLE MARC Records in #{collection.key} > 0000000000000.mrc record count = 2")
        expect(MarcRecord.count).to eq(1)
        marc_record = MarcRecord.first
        expect(marc_record.selected).to be true
        expect(marc_record.updated).to eq('1970-01-01 00:00:00.000000000 +0000')
        expect(marc_record.content).to eq('content')
        expect(marc_record.count).to eq(2)
        expect(marc_record.mrc).to eq('mrc')
        expect(marc_record.doi).to eq('doi')
        expect(marc_record.parsed).to be true
      end
    end

    context 'when standard error' do
      before { allow(reader).to receive(:each).and_raise(StandardError) }

      it do
        expect(synchronize_marc_records).to contain_exactly("ERROR: StandardError reading MARC Record in #{collection.key} > 0000000000000.mrc")
        expect(MarcRecord.count).to eq(1)
        marc_record = MarcRecord.first
        expect(marc_record.selected).to be false
        expect(marc_record.updated).to eq('1970-01-01 00:00:00.000000000 +0000')
        expect(marc_record.content).to be nil
        expect(marc_record.count).to eq(0)
        expect(marc_record.mrc).to be nil
        expect(marc_record.doi).to be nil
        expect(marc_record.parsed).to be false
      end
    end
  end

  describe '#synchronize_kbart_files' do
    subject(:synchronize_kbart_files) { described_class.new.synchronize_kbart_files(collection) }

    it 'new kbart' do
      expect(synchronize_kbart_files).to be_empty
      expect(KbartFile.count).to eq(1)
    end

    it 'logs orphan kbart record' do
      kbart_file = create(:kbart_file)
      expect(KbartFile.count).to eq(1)
      expect(synchronize_kbart_files).to contain_exactly("WARNING: KBART FILE NOT FOUND #{kbart_file.name}")
      expect(KbartFile.count).to eq(2)
    end

    context 'when kbart record is verified' do
      let(:kbart_file) { instance_double(KbartFile, 'kbart_file', verified: true) }
      let(:work) { instance_double(LibPtgBox::Work, 'work', marc?: true, marc: marc) }
      let(:marc) { instance_double(LibPtgBox::Unmarshaller::Marc, 'marc', doi: 'doi') }
      let(:marc_record) { instance_double(MarcRecord, 'marc_record', doi: marc.doi, selected: selected) }
      let(:selected) { false }

      before do
        allow(KbartFile).to receive(:find_or_create_by!).with(folder: collection.key, name: selection.name, year: selection.year).and_return(kbart_file)
        allow(selection).to receive(:works).and_return([work])
        allow(MarcRecord).to receive(:find_by).with(folder: collection.key, doi: marc.doi).and_return(marc_record)
        allow(kbart_file).to receive(:verified=).with(false)
        allow(kbart_file).to receive(:save!)
      end

      it 'when unselected' do
        expect(synchronize_kbart_files).to be_empty
        expect(kbart_file).not_to have_received(:verified=).with(false)
        expect(kbart_file).not_to have_received(:save!)
      end

      context 'when selected' do
        let(:selected) { true }

        it do
          expect(synchronize_kbart_files).to contain_exactly("INFO: At least one MARC record in #{selection.name} has been updated.")
          expect(kbart_file).to have_received(:verified=).with(false)
          expect(kbart_file).to have_received(:save!)
        end
      end
    end
  end
end
