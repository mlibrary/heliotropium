# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AssembleMarcFiles::AssembleMarcFiles do
  subject(:program) { described_class.new(ftp_fulcrum_org) }

  let(:ftp_fulcrum_org) { instance_double(FtpFulcrumOrg::FtpFulcrumOrg, 'ftp_fulcrum_org', publishers: [publisher]) }
  let(:publisher) { instance_double(FtpFulcrumOrg::Publisher, 'publisher', key: publisher_key, name: publisher_name, collections: [collection], catalog: catalog) }
  let(:publisher_key) { 'publisher' }
  let(:publisher_name) { 'Publisher' }
  let(:collection) { instance_double(FtpFulcrumOrg::Collection, 'collection', name: collection_name, updated: collection_updated, works: [work]) }
  let(:collection_name) { "Selection_#{collection_year}" }
  let(:collection_year) { Date.today.year }
  let(:collection_updated) { Date.today }
  let(:work) { instance_double(FtpFulcrumOrg::Work, 'work', doi: work_doi, url: work_url, title: 'title', date: 'date', print: 'print', online: 'online', name: work_name, marc?: work_marc, marc: marc) }
  let(:work_doi) { '10.3998/mpub.123456789' }
  let(:work_url) { "https://doi.org/#{work_doi}" }
  let(:work_name) { 'Star Wars' }
  let(:work_marc) { false }
  let(:marc) { instance_double(FtpFulcrumOrg::Marc, 'marc', entry: entry, doi: work_doi, to_mrc: 'to_mrc') }
  let(:entry) { instance_double(MARC::Record, 'entry') }
  let(:catalog) { instance_double(FtpFulcrumOrg::Catalog, 'catalog') }

  before do
    FtpFulcrumOrg.chdir_ftp_fulcrum_org_dir
    program
    allow(FtpFulcrumOrg::FtpFulcrumOrg).to receive(:new).and_return(ftp_fulcrum_org)
    allow(collection).to receive(:publisher).and_return(publisher)
  end

  describe '#assemble_marc_files' do
    subject(:assemble_marc_files) { program.assemble_marc_files(publisher, false) }

    let(:record) { instance_double(KbartFile, 'record', id: 'id', updated: record_updated, verified: true) }
    let(:record_updated) { collection_updated }

    before do
      allow(KbartFile).to receive(:find_by).with(folder: publisher.key, name: collection.name).and_return(record)
      allow(program).to receive(:upload_marc_files).with(publisher).and_return("upload\n")
    end

    it do
      assemble_marc_files
      expect(program.errors).to be_empty
    end

    context 'when collection updated' do
      let(:month) { Date.today.month }
      let(:record_updated) { Date.yesterday }
      let(:updated) { 'updated' }

      before do
        allow(record).to receive(:verified=).with(true)
        allow(program).to receive(:recreate_collection_marc_files).with(record, collection).and_return("select\n")
        allow(program).to receive(:recreate_publisher_marc_files).with(publisher).and_return("collect\n")
        allow(record).to receive(:updated=).with(collection_updated)
        allow(record).to receive(:save!).with(no_args)
      end

      it do
        assemble_marc_files
        expect(program.errors).to be_empty
      end

      context 'when collection year updated' do
        let(:collection_year) { Date.today.year }

        it do
          assemble_marc_files
          expect(program.errors).to be_empty
        end
      end
    end
  end

  describe '#recreate_collection_marc_files' do
    subject(:recreate_collection_marc_files) { program.recreate_collection_marc_files(record, collection) }

    let(:record) { instance_double(KbartFile, 'record') }
    let(:filename) { collection.name }
    let(:mrc_file) { instance_double(File, 'mrc_file') }
    let(:xml_file) { instance_double(File, 'xml_file') }

    before do
      allow(record).to receive(:verified=).with(false)
    end

    it do
      recreate_collection_marc_files
      expect(program.errors).to contain_exactly("", "#{filename} MISSING MARC Record", "https://doi.org/10.3998/mpub.123456789", "online (online)", "print (print)", "title (date)")
    end

    context 'when catalog marc record' do
      let(:work_marc) { true }

      let(:writer) { instance_double(MARC::Writer, 'writer') }
      let(:xml_writer) { instance_double(MARC::XMLWriter, 'xml_writer') }
      let(:kbart_marc) { instance_double(KbartMarc, 'kbart_marc', updated: Date.parse('1970-01-01')) }

      before do
        allow(MARC::Writer).to receive(:new).with("#{collection_name}.mrc").and_return(writer)
        allow(writer).to receive(:write).with(entry)
        allow(writer).to receive(:close)
        allow(MARC::XMLWriter).to receive(:new).with("#{collection_name}.xml").and_return(xml_writer)
        allow(xml_writer).to receive(:write).with(entry)
        allow(xml_writer).to receive(:close)
        allow(KbartMarc).to receive(:find_or_create_by!).with(folder: publisher_key, file: collection_name, doi: work.doi).and_return(kbart_marc)
        allow(kbart_marc).to receive(:save!)
      end

      it do
        recreate_collection_marc_files
        expect(MARC::Writer).to have_received(:new).with("#{collection_name}.mrc")
        expect(writer).to have_received(:write).with(entry)
        expect(writer).to have_received(:close)
        expect(MARC::XMLWriter).to have_received(:new).with("#{collection_name}.xml")
        expect(xml_writer).to have_received(:write).with(entry)
        expect(xml_writer).to have_received(:close)
        expect(KbartMarc).to have_received(:find_or_create_by!).with(folder: publisher_key, file: collection_name, doi: work.doi)
        expect(kbart_marc).not_to have_received(:updated).with(collection_updated)
        expect(kbart_marc).not_to have_received(:save!)
        expect(program.errors).to be_empty
      end
    end
  end

  describe '#create_collection_marc_delta_files' do
    subject(:create_collection_marc_delta_files) { program.create_collection_marc_delta_files(collection) }

    let(:today) { Time.now }
    let(:filename) { "#{collection.name}_update_#{format('%04d-%02d-%02d', today.year, today.month, 15)}" }
    let(:writer) { instance_double(MARC::Writer, 'writer') }
    let(:xml_writer) { instance_double(MARC::XMLWriter, 'xml_writer') }

    before do
      allow(MARC::Writer).to receive(:new).with("#{filename}.mrc").and_return(writer)
      allow(writer).to receive(:write).with(entry)
      allow(writer).to receive(:close)
      allow(MARC::XMLWriter).to receive(:new).with("#{filename}.xml").and_return(xml_writer)
      allow(xml_writer).to receive(:write).with(entry)
      allow(xml_writer).to receive(:close)
    end

    it do
      create_collection_marc_delta_files
      expect(MARC::Writer).not_to have_received(:new).with("#{filename}.mrc")
      expect(writer).not_to have_received(:write).with(entry)
      expect(writer).not_to have_received(:close)
      expect(MARC::XMLWriter).not_to have_received(:new).with("#{filename}.xml")
      expect(xml_writer).not_to have_received(:write).with(entry)
      expect(xml_writer).not_to have_received(:close)
      expect(program.errors).to be_empty
    end

    context 'when kbart marc' do
      let(:work_marc) { true }
      let(:kbart_marc) { instance_double(KbartMarc, 'kbart_marc', doi: 'doi') }
      let(:updated) { Date.new(today.year, today.month, 1) } # Greater than previous delta and less than or equal this delta

      before do
        allow(KbartMarc).to receive(:find_by!).with(folder: publisher_key, file: collection_name, doi: work.doi).and_return(kbart_marc)
        allow(kbart_marc).to receive(:updated).and_return(updated)
      end

      it do
        create_collection_marc_delta_files
        expect(MARC::Writer).to have_received(:new).with("#{filename}.mrc")
        expect(writer).to have_received(:write).with(entry)
        expect(writer).to have_received(:close)
        expect(MARC::XMLWriter).to have_received(:new).with("#{filename}.xml")
        expect(xml_writer).to have_received(:write).with(entry)
        expect(xml_writer).to have_received(:close)
        expect(program.errors).to be_empty
      end
    end
  end

  describe '#recreate_publisher_marc_files' do
    subject(:recreate_publisher_marc_files) { program.recreate_publisher_marc_files(publisher) }

    it do
      recreate_publisher_marc_files
      expect(program.errors).to be_empty
    end

    context 'when catalog marc record' do
      let(:work_marc) { true }
      let(:complete_name) { "#{publisher_name}_Complete" }
      let(:writer) { instance_double(MARC::Writer, 'writer') }
      let(:xml_writer) { instance_double(MARC::XMLWriter, 'xml_writer') }

      before do
        allow(MARC::Writer).to receive(:new).with("#{complete_name}.mrc").and_return(writer)
        allow(writer).to receive(:write).with(entry)
        allow(writer).to receive(:close)
        allow(MARC::XMLWriter).to receive(:new).with("#{complete_name}.xml").and_return(xml_writer)
        allow(xml_writer).to receive(:write).with(entry)
        allow(xml_writer).to receive(:close)
      end

      it do
        recreate_publisher_marc_files
        expect(MARC::Writer).to have_received(:new).with("#{complete_name}.mrc")
        expect(writer).to have_received(:write).with(entry)
        expect(writer).to have_received(:close)
        expect(MARC::XMLWriter).to have_received(:new).with("#{complete_name}.xml")
        expect(xml_writer).to have_received(:write).with(entry)
        expect(xml_writer).to have_received(:close)
        expect(program.errors).to be_empty
      end
    end
  end

  describe '#upload_marc_files' do
    subject(:upload_marc_files) { program.upload_marc_files(publisher) }

    let(:entries) { ['.', '..'] }

    before do
      allow(Dir).to receive(:entries).with(Dir.pwd).and_return(entries)
      allow(publisher).to receive(:upload_marc_file)
    end

    it do
      expect(upload_marc_files).to be_empty
      expect(publisher).not_to have_received(:upload_marc_file)
      expect(program.errors).to be_empty
    end

    context 'when marc files' do
      let(:month) { Date.today.month }
      let(:month_string) { format("%02d", month) }

      let(:entries) do
        [
          '.',
          '..',
          "#{collection.name}.mrc",
          "#{collection.name}.xml",
          "#{collection.name}#{format('-%02d', month)}.mrc",
          "#{collection.name}#{format('-%02d', month)}.xml",
          "#{publisher.name}_Complete.mrc",
          "#{publisher.name}_Complete.xml"
        ]
      end

      before do
        allow(File).to receive(:read).with(anything).and_return('content')
      end

      it do
        expect(upload_marc_files).to match_array ["#{collection_name}.xml", "#{collection_name}.mrc", "#{collection_name}-#{month_string}.xml", "#{collection_name}-#{month_string}.mrc", "#{publisher.name}_Complete.xml", "#{publisher.name}_Complete.mrc"]
        expect(publisher).not_to have_received(:upload_marc_file).with('.')
        expect(publisher).not_to have_received(:upload_marc_file).with('..')
        expect(publisher).to have_received(:upload_marc_file).with("#{collection.name}.mrc")
        expect(publisher).to have_received(:upload_marc_file).with("#{collection.name}.xml")
        expect(publisher).to have_received(:upload_marc_file).with("#{collection.name}#{format('-%02d', month)}.mrc")
        expect(publisher).to have_received(:upload_marc_file).with("#{collection.name}#{format('-%02d', month)}.xml")
        expect(publisher).to have_received(:upload_marc_file).with("#{publisher.name}_Complete.mrc")
        expect(publisher).to have_received(:upload_marc_file).with("#{publisher.name}_Complete.xml")
        expect(program.errors).to be_empty
      end

      context 'with same checksum' do
        let(:record) { instance_double(MarcFile, 'record', checksum: Digest::MD5.hexdigest('content')) }

        before do
          allow(MarcFile).to receive(:find_or_create_by!).with(anything).and_return(record)
        end

        it do
          expect(upload_marc_files).to be_empty
          expect(publisher).not_to have_received(:upload_marc_file).with('.')
          expect(publisher).not_to have_received(:upload_marc_file).with('..')
          expect(publisher).not_to have_received(:upload_marc_file).with("#{collection.name}.mrc")
          expect(publisher).not_to have_received(:upload_marc_file).with("#{collection.name}.xml")
          expect(publisher).not_to have_received(:upload_marc_file).with("#{collection.name}#{format('-%02d', month)}.mrc")
          expect(publisher).not_to have_received(:upload_marc_file).with("#{collection.name}#{format('-%02d', month)}.xml")
          expect(publisher).not_to have_received(:upload_marc_file).with("#{publisher.name}_Complete.mrc")
          expect(publisher).not_to have_received(:upload_marc_file).with("#{publisher.name}_Complete.xml")
          expect(program.errors).to be_empty
        end
      end

      context 'when upload error' do
        before do
          allow(publisher).to receive(:upload_marc_file).with("#{publisher.name}_Complete.mrc").and_raise(StandardError)
        end

        it do
          expect(upload_marc_files).to match_array ["#{collection_name}.xml", "#{collection_name}.mrc", "#{collection_name}-#{month_string}.xml", "#{collection_name}-#{month_string}.mrc", "#{publisher.name}_Complete.xml"]
          expect(publisher).not_to have_received(:upload_marc_file).with('.')
          expect(publisher).not_to have_received(:upload_marc_file).with('..')
          expect(publisher).to have_received(:upload_marc_file).with("#{collection.name}.mrc")
          expect(publisher).to have_received(:upload_marc_file).with("#{collection.name}.xml")
          expect(publisher).to have_received(:upload_marc_file).with("#{collection.name}#{format('-%02d', month)}.mrc")
          expect(publisher).to have_received(:upload_marc_file).with("#{collection.name}#{format('-%02d', month)}.xml")
          expect(publisher).to have_received(:upload_marc_file).with("#{publisher.name}_Complete.mrc")
          expect(publisher).to have_received(:upload_marc_file).with("#{publisher.name}_Complete.xml")
          expect(program.errors).to contain_exactly("ERROR Uploading #{"#{publisher.name}_Complete.mrc"} StandardError")
        end
      end
    end
  end
end
