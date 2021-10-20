# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FtpFulcrumOrg::FtpFulcrumOrg do
  subject { ftp_fulcrum_org }

  let(:ftp_fulcrum_org) { described_class.new(sftp) }
  let(:sftp) { instance_double(Net::SFTP::Session, 'sftp') }

  it { is_expected.to be_an_instance_of(described_class) }

  it '#initialize' do
    ftp_fulcrum_org
    expect(Dir.pwd).to eq(Rails.root.join('tmp', 'ftp_fulcrum_org').to_s)
  end

  describe '#publishers' do
    subject(:publishers) { ftp_fulcrum_org.publishers }

    it { expect(publishers.count).to eq 1 }
  end

  describe '#synchronize_marc_records' do
    subject(:synchronize_marc_records) { ftp_fulcrum_org.synchronize_marc_records(publisher) }

    let(:publisher) { instance_double(FtpFulcrumOrg::Publisher, 'publisher', key: key, catalog: catalog) }
    let(:key) { 'key' }
    let(:catalog) { instance_double(FtpFulcrumOrg::Catalog, 'catalog', marc_files: marc_files) }
    let(:marc_files) { [marc_file] }
    let(:marc_file) { instance_double(FtpFulcrumOrg::MarcFile, 'marc_file', name: '0000000000000.mrc', updated: updated, content: content) }
    let(:updated) { Date.parse('1970-01-01') }
    let(:content) { 'content' }
    let(:string_io) { instance_double(StringIO, 'string_io') }
    let(:reader) { instance_double(MARC::Reader, 'reader') }
    let(:record) { instance_double(MARC::Record, 'record') }
    let(:marc) { instance_double(FtpFulcrumOrg::Marc, 'marc', doi: 'doi') }

    before do
      allow(MARC::Reader).to receive(:new).with(string_io, external_encoding: "UTF-8", validate_encoding: true).and_return(reader)
      allow(StringIO).to receive(:new).with(content).and_return(string_io)
      allow(reader).to receive(:each).and_yield(record)
      allow(record).to receive(:to_marc).and_return('mrc')
      allow(FtpFulcrumOrg::Marc).to receive(:new).with(record).and_return(marc)
    end

    it 'new file' do
      expect(synchronize_marc_records).to contain_exactly("INFO: MARC Record updated in #{publisher.key} > 0000000000000.mrc")
      expect(MarcRecord.count).to eq(1)
      marc_record = MarcRecord.first
      expect(marc_record.selected).to be true
      expect(marc_record.updated).to eq(Date.parse('1970-01-01'))
      expect(marc_record.content).to eq('content')
      expect(marc_record.mrc).to eq('mrc')
      expect(marc_record.doi).to eq('doi')
      expect(marc_record.count).to eq(1)
      expect(marc_record.parsed).to be true
    end

    it 'logs orphan marc record' do
      marc_record = create(:marc_record, folder: publisher.key)
      expect(MarcRecord.count).to eq(1)
      expect(synchronize_marc_records).to contain_exactly("WARNING: MARC FILE NOT FOUND #{marc_record.folder} > #{marc_record.file}", "INFO: MARC Record updated in #{publisher.key} > 0000000000000.mrc")
      expect(MarcRecord.count).to eq(2)
    end

    context 'when new file is empty' do
      before { allow(reader).to receive(:each).and_return(nil) }

      it do
        expect(synchronize_marc_records).to contain_exactly("INFO: MARC Record updated in #{publisher.key} > 0000000000000.mrc", "ERROR: NO MARC Record in #{publisher.key} > 0000000000000.mrc record count = 0")
        expect(MarcRecord.count).to eq(1)
        marc_record = MarcRecord.first
        expect(marc_record.selected).to be true
        expect(marc_record.updated).to eq(Date.parse('1970-01-01'))
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
        expect(synchronize_marc_records).to contain_exactly("INFO: MARC Record updated in #{publisher.key} > 0000000000000.mrc", "WARNING: MULTIPLE MARC Records in #{publisher.key} > 0000000000000.mrc record count = 2")
        expect(MarcRecord.count).to eq(1)
        marc_record = MarcRecord.first
        expect(marc_record.selected).to be true
        expect(marc_record.updated).to eq(Date.parse('1970-01-01'))
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
        expect(synchronize_marc_records).to contain_exactly("ERROR: StandardError reading MARC Record in #{publisher.key} > 0000000000000.mrc")
        expect(MarcRecord.count).to eq(1)
        marc_record = MarcRecord.first
        expect(marc_record.selected).to be false
        expect(marc_record.updated).to eq(Date.parse('1970-01-01'))
        expect(marc_record.content).to be nil
        expect(marc_record.count).to eq(0)
        expect(marc_record.mrc).to be nil
        expect(marc_record.doi).to be nil
        expect(marc_record.parsed).to be false
      end
    end
  end

  describe '#synchronize_kbart_files' do
    subject(:synchronize_kbart_files) { ftp_fulcrum_org.synchronize_kbart_files(publisher) }

    let(:publisher) { instance_double(FtpFulcrumOrg::Publisher, 'publisher', key: key, collections: collections) } # , catalog: catalog) }
    let(:key) { 'key' }
    let(:collections) { [collection] }
    let(:collection) { instance_double(FtpFulcrumOrg::Collection, 'collection', name: 'collection') }

    it 'new kbart' do
      expect(synchronize_kbart_files).to be_empty
      expect(KbartFile.count).to eq(1)
    end

    it 'logs orphan kbart record' do
      db_kbart_file = create(:kbart_file, folder: publisher.key)
      expect(KbartFile.count).to eq(1)
      expect(synchronize_kbart_files).to contain_exactly("WARNING: KBART FILE NOT FOUND #{db_kbart_file.name}")
      expect(KbartFile.count).to eq(2)
    end

    context 'when kbart record is verified' do
      let(:db_kbart_file) { instance_double(KbartFile, 'db_kbart_file', verified: true) }
      let(:work) { instance_double(FtpFulcrumOrg::Work, 'work', marc?: true, marc: marc) }
      let(:marc) { instance_double(FtpFulcrumOrg::Marc, 'marc', doi: 'doi') }
      let(:marc_record) { instance_double(MarcRecord, 'marc_record', doi: marc.doi, selected: selected) }
      let(:selected) { false }

      before do
        allow(KbartFile).to receive(:find_or_create_by!).with(folder: publisher.key, name: collection.name).and_return(db_kbart_file)
        allow(collection).to receive(:works).and_return([work])
        allow(MarcRecord).to receive(:find_by).with(folder: publisher.key, doi: marc.doi).and_return(marc_record)
        allow(db_kbart_file).to receive(:verified=).with(false)
        allow(db_kbart_file).to receive(:save!)
      end

      it 'when unselected' do
        expect(synchronize_kbart_files).to be_empty
        expect(db_kbart_file).not_to have_received(:verified=).with(false)
        expect(db_kbart_file).not_to have_received(:save!)
      end

      context 'when selected' do
        let(:selected) { true }

        it do
          expect(synchronize_kbart_files).to contain_exactly("INFO: At least one MARC record in #{collection.name} has been updated.")
          expect(db_kbart_file).to have_received(:verified=).with(false)
          expect(db_kbart_file).to have_received(:save!)
        end
      end
    end
  end
end
