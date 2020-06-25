# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AssembleMarcFiles::AssembleMarcFiles do
  subject(:program) { described_class.new(lib_ptg_box) }

  let(:lib_ptg_box) { instance_double(LibPtgBox::LibPtgBox, 'lib_ptg_box', collections: [collection]) }
  let(:collection) { instance_double(LibPtgBox::Collection, 'collection', key: collection_key, name: collection_name, selections: [selection], catalog: catalog) }
  let(:collection_key) { 'collection' }
  let(:collection_name) { 'Collection' }
  let(:selection) { instance_double(LibPtgBox::Selection, 'selection', name: selection_name, updated: selection_updated, works: [work]) }
  let(:selection_name) { "Selection_#{selection_year}" }
  let(:selection_year) { Date.today.year }
  let(:selection_updated) { Date.today }
  let(:work) { instance_double(LibPtgBox::Work, 'work', doi: work_doi, url: work_url, title: 'title', date: 'date', print: 'print', online: 'online', name: work_name, marc?: work_marc, marc: marc) }
  let(:work_doi) { '10.3998/mpub.123456789' }
  let(:work_url) { "https://doi.org/#{work_doi}" }
  let(:work_name) { 'Star Wars' }
  let(:work_marc) { false }
  let(:marc) { instance_double(LibPtgBox::Unmarshaller::Marc, 'marc', entry: entry, doi: work_doi, to_mrc: 'to_mrc') }
  let(:entry) { instance_double(MARC::Record, 'entry') }
  let(:catalog) { instance_double(LibPtgBox::Catalog, 'catalog') }
  let(:umpebc) { 'UMPEBC' }

  before do
    LibPtgBox.chdir_lib_ptg_box_dir
    program
    allow(LibPtgBox::LibPtgBox).to receive(:new).and_return(lib_ptg_box)
    allow(selection).to receive(:collection).and_return(collection)
  end

  describe '#assemble_marc_files' do
    subject(:assemble_marc_files) { program.assemble_marc_files(collection, false) }

    let(:record) { instance_double(KbartFile, 'record', id: 'id', updated: record_updated, verified: true) }
    let(:record_updated) { selection_updated }

    before do
      allow(KbartFile).to receive(:find_by).with(folder: collection.key, name: selection.name).and_return(record)
      allow(program).to receive(:upload_marc_files).with(collection).and_return("upload\n")
    end

    it do
      assemble_marc_files
      expect(program.errors).to be_empty
    end

    context 'when selection updated' do
      let(:month) { Date.today.month }
      let(:record_updated) { Date.yesterday }
      let(:updated) { 'updated' }

      before do
        allow(record).to receive(:verified=).with(true)
        allow(program).to receive(:recreate_selection_marc_files).with(record, selection).and_return("select\n")
        allow(program).to receive(:recreate_collection_marc_files).with(collection).and_return("collect\n")
        allow(record).to receive(:updated=).with(selection_updated)
        allow(record).to receive(:save!).with(no_args)
      end

      it do
        assemble_marc_files
        expect(program.errors).to be_empty
      end

      context 'when selection year updated' do
        let(:selection_year) { Date.today.year }

        it do
          assemble_marc_files
          expect(program.errors).to be_empty
        end
      end
    end
  end

  describe '#recreate_selection_marc_files' do
    subject(:recreate_selection_marc_files) { program.recreate_selection_marc_files(record, selection) }

    let(:record) { instance_double(KbartFile, 'record') }
    let(:filename) { selection.name }
    let(:mrc_file) { instance_double(File, 'mrc_file') }
    let(:xml_file) { instance_double(File, 'xml_file') }

    before do
      allow(record).to receive(:verified=).with(false)
    end

    it do
      recreate_selection_marc_files
      expect(program.errors).to contain_exactly("", "#{filename} MISSING MARC Record", "https://doi.org/10.3998/mpub.123456789", "online (online)", "print (print)", "title (date)")
    end

    context 'when catalog marc record' do
      let(:work_marc) { true }

      let(:writer) { instance_double(MARC::Writer, 'writer') }
      let(:xml_writer) { instance_double(MARC::XMLWriter, 'xml_writer') }
      let(:kbart_marc) { instance_double(KbartMarc, 'kbart_marc', updated: Date.parse('1970-01-01')) }

      before do
        allow(MARC::Writer).to receive(:new).with("#{selection_name}.mrc").and_return(writer)
        allow(writer).to receive(:write).with(entry)
        allow(writer).to receive(:close)
        allow(MARC::XMLWriter).to receive(:new).with("#{selection_name}.xml").and_return(xml_writer)
        allow(xml_writer).to receive(:write).with(entry)
        allow(xml_writer).to receive(:close)
        allow(KbartMarc).to receive(:find_or_create_by!).with(folder: collection_key, file: selection_name, doi: work.doi).and_return(kbart_marc)
        allow(kbart_marc).to receive(:save!)
      end

      it do
        recreate_selection_marc_files
        expect(MARC::Writer).to have_received(:new).with("#{selection_name}.mrc")
        expect(writer).to have_received(:write).with(entry)
        expect(writer).to have_received(:close)
        expect(MARC::XMLWriter).to have_received(:new).with("#{selection_name}.xml")
        expect(xml_writer).to have_received(:write).with(entry)
        expect(xml_writer).to have_received(:close)
        expect(KbartMarc).to have_received(:find_or_create_by!).with(folder: collection_key, file: selection_name, doi: work.doi)
        expect(kbart_marc).not_to have_received(:updated).with(selection_updated)
        expect(kbart_marc).not_to have_received(:save!)
        expect(program.errors).to be_empty
      end
    end
  end

  describe '#create_selection_marc_delta_files' do
    subject(:create_selection_marc_delta_files) { program.create_selection_marc_delta_files(selection) }

    let(:today) { Time.now }
    let(:filename) { selection.name + '_update_' + format("%04d-%02d-%02d", today.year, today.month, 15) }
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
      create_selection_marc_delta_files
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
        allow(KbartMarc).to receive(:find_by!).with(folder: collection_key, file: selection_name, doi: work.doi).and_return(kbart_marc)
        allow(kbart_marc).to receive(:updated).and_return(updated)
      end

      it do
        create_selection_marc_delta_files
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

  describe '#recreate_collection_marc_files' do
    subject(:recreate_collection_marc_files) { program.recreate_collection_marc_files(collection) }

    it do
      recreate_collection_marc_files
      expect(program.errors).to be_empty
    end

    context 'when catalog marc record' do
      let(:work_marc) { true }
      let(:complete_name) { "#{collection_name}_Complete" }
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
        recreate_collection_marc_files
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
    subject(:upload_marc_files) { program.upload_marc_files(collection) }

    let(:entries) { ['.', '..'] }

    before do
      allow(Dir).to receive(:entries).with(Dir.pwd).and_return(entries)
      allow(collection).to receive(:upload_marc_file)
    end

    it do
      expect(upload_marc_files).to be_empty
      expect(collection).not_to have_received(:upload_marc_file)
      expect(program.errors).to be_empty
    end

    context 'when marc files' do
      let(:month) { Date.today.month }
      let(:month_string) { format("%02d", month) }

      let(:entries) do
        [
          '.',
          '..',
          selection.name + '.mrc',
          selection.name + '.xml',
          selection.name + format("-%02d", month) + '.mrc',
          selection.name + format("-%02d", month) + '.xml',
          collection.name + '_Complete.mrc',
          collection.name + '_Complete.xml'
        ]
      end

      before do
        allow(File).to receive(:read).with(anything).and_return('content')
      end

      it do
        expect(upload_marc_files).to match_array ["#{selection_name}.xml", "#{selection_name}.mrc", "#{selection_name}-#{month_string}.xml", "#{selection_name}-#{month_string}.mrc", "#{collection.name}_Complete.xml", "#{collection.name}_Complete.mrc"]
        expect(collection).not_to have_received(:upload_marc_file).with('.')
        expect(collection).not_to have_received(:upload_marc_file).with('..')
        expect(collection).to have_received(:upload_marc_file).with(selection.name + '.mrc')
        expect(collection).to have_received(:upload_marc_file).with(selection.name + '.xml')
        expect(collection).to have_received(:upload_marc_file).with(selection.name + format("-%02d", month) + '.mrc')
        expect(collection).to have_received(:upload_marc_file).with(selection.name + format("-%02d", month) + '.xml')
        expect(collection).to have_received(:upload_marc_file).with(collection.name + '_Complete.mrc')
        expect(collection).to have_received(:upload_marc_file).with(collection.name + '_Complete.xml')
        expect(program.errors).to be_empty
      end

      context 'with same checksum' do
        let(:record) { instance_double(MarcFile, 'record', checksum: Digest::MD5.hexdigest('content')) }

        before do
          allow(MarcFile).to receive(:find_or_create_by!).with(anything).and_return(record)
        end

        it do
          expect(upload_marc_files).to be_empty
          expect(collection).not_to have_received(:upload_marc_file).with('.')
          expect(collection).not_to have_received(:upload_marc_file).with('..')
          expect(collection).not_to have_received(:upload_marc_file).with(selection.name + '.mrc')
          expect(collection).not_to have_received(:upload_marc_file).with(selection.name + '.xml')
          expect(collection).not_to have_received(:upload_marc_file).with(selection.name + format("-%02d", month) + '.mrc')
          expect(collection).not_to have_received(:upload_marc_file).with(selection.name + format("-%02d", month) + '.xml')
          expect(collection).not_to have_received(:upload_marc_file).with(collection.name + '_Complete.mrc')
          expect(collection).not_to have_received(:upload_marc_file).with(collection.name + '_Complete.xml')
          expect(program.errors).to be_empty
        end
      end

      context 'when upload error' do
        before do
          allow(collection).to receive(:upload_marc_file).with(collection.name + '_Complete.mrc').and_raise(StandardError)
        end

        it do
          expect(upload_marc_files).to match_array ["#{selection_name}.xml", "#{selection_name}.mrc", "#{selection_name}-#{month_string}.xml", "#{selection_name}-#{month_string}.mrc", "#{collection.name}_Complete.xml"]
          expect(collection).not_to have_received(:upload_marc_file).with('.')
          expect(collection).not_to have_received(:upload_marc_file).with('..')
          expect(collection).to have_received(:upload_marc_file).with(selection.name + '.mrc')
          expect(collection).to have_received(:upload_marc_file).with(selection.name + '.xml')
          expect(collection).to have_received(:upload_marc_file).with(selection.name + format("-%02d", month) + '.mrc')
          expect(collection).to have_received(:upload_marc_file).with(selection.name + format("-%02d", month) + '.xml')
          expect(collection).to have_received(:upload_marc_file).with(collection.name + '_Complete.mrc')
          expect(collection).to have_received(:upload_marc_file).with(collection.name + '_Complete.xml')
          expect(program.errors).to contain_exactly("ERROR Uploading #{collection.name + '_Complete.mrc'} StandardError")
        end
      end
    end
  end
end
