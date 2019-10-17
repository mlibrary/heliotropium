# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AssembleMarcFiles::AssembleMarcFiles do
  subject(:program) { described_class.new(lib_ptg_box) }

  let(:lib_ptg_box) { instance_double(LibPtgBox::LibPtgBox, 'lib_ptg_box', collections: [collection]) }
  let(:collection) { instance_double(LibPtgBox::Collection, 'collection', name: collection_name, selections: [selection]) }
  let(:collection_name) { 'Collection Metadata' }
  let(:selection) { instance_double(LibPtgBox::Selection, 'selection', name: selection_name, year: selection_year, updated: selection_updated, works: [work]) }
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
  let(:umpebc_metadata) { 'UMPEBC Metadata' }

  before do
    LibPtgBox.chdir_lib_ptg_box_dir
    program
    allow(LibPtgBox::LibPtgBox).to receive(:new).and_return(lib_ptg_box)
    allow(selection).to receive(:collection).and_return(collection)
  end

  describe '#execute' do
    subject(:execute) { program.execute }

    before do
      allow(program).to receive(:assemble_marc_files).with(collection)
    end

    it do
      execute
      expect(program).not_to have_received(:assemble_marc_files).with(collection)
      expect(program.errors).to be_empty
    end

    context 'when UMPEBC Metadata folder' do
      let(:collection_name) { umpebc_metadata }

      it do
        execute
        expect(program).to have_received(:assemble_marc_files).with(collection)
        expect(program.errors).to be_empty
      end
    end
  end

  describe '#recreate_selection_marc_files' do
    subject(:recreate_selection_marc_files) { program.recreate_selection_marc_files(record, selection) }

    let(:record) { instance_double(UmpebcKbart, 'record') }
    let(:filename) { selection.name }
    let(:mrc_file) { instance_double(File, 'mrc_file') }
    let(:xml_file) { instance_double(File, 'xml_file') }

    before do
      allow(record).to receive(:verified=).with(false)
    end

    it do
      recreate_selection_marc_files
      expect(program.errors).to contain_exactly("", "#{filename} MISSING Cataloging MARC record", "https://doi.org/10.3998/mpub.123456789", "online (online)", "print (print)", "title (date)")
    end

    context 'when catalog marc record' do
      let(:work_marc) { true }

      let(:writer) { instance_double(MARC::Writer, 'writer') }
      let(:xml_writer) { instance_double(MARC::XMLWriter, 'xml_writer') }
      let(:umpebc_marc) { instance_double(UmpebcMarc, 'umpebc_marc') }

      before do
        allow(MARC::Writer).to receive(:new).with("#{selection_name}.mrc").and_return(writer)
        allow(writer).to receive(:write).with(entry)
        allow(writer).to receive(:close)
        allow(MARC::XMLWriter).to receive(:new).with("#{selection_name}.xml").and_return(xml_writer)
        allow(xml_writer).to receive(:write).with(entry)
        allow(xml_writer).to receive(:close)
        allow(UmpebcMarc).to receive(:find_or_create_by!).with(doi: work.doi).and_return(umpebc_marc)
        allow(umpebc_marc).to receive(:mrc=).with(marc.to_mrc).and_return(marc.to_mrc)
        allow(umpebc_marc).to receive(:year=).with(selection_year)
        allow(umpebc_marc).to receive(:save!)
      end

      it do
        recreate_selection_marc_files
        expect(MARC::Writer).to have_received(:new).with("#{selection_name}.mrc")
        expect(writer).to have_received(:write).with(entry)
        expect(writer).to have_received(:close)
        expect(MARC::XMLWriter).to have_received(:new).with("#{selection_name}.xml")
        expect(xml_writer).to have_received(:write).with(entry)
        expect(xml_writer).to have_received(:close)
        expect(UmpebcMarc).to have_received(:find_or_create_by!).with(doi: work.doi)
        expect(umpebc_marc).to have_received(:mrc=).with(marc.to_mrc)
        expect(umpebc_marc).to have_received(:year=).with(selection_year)
        expect(umpebc_marc).to have_received(:save!)
        expect(program.errors).to be_empty
      end
    end
  end

  describe '#recreate_collection_month_marc_file' do
    subject(:recreate_collection_month_marc_file) { program.recreate_collection_month_marc_file(collection) }

    let(:month) { Date.today.month }
    let(:filename) { selection.name + format("-%02d", month) }
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
      recreate_collection_month_marc_file
      expect(MARC::Writer).to have_received(:new).with("#{filename}.mrc")
      expect(writer).not_to have_received(:write).with(entry)
      expect(writer).to have_received(:close)
      expect(MARC::XMLWriter).to have_received(:new).with("#{filename}.xml")
      expect(xml_writer).not_to have_received(:write).with(entry)
      expect(xml_writer).to have_received(:close)
      expect(program.errors).to be_empty
    end

    context 'when umpebc marc' do
      let(:umpebc_marc) { instance_double(UmpebcMarc, 'umpebc_marc', mrc: 'mrc') }

      before do
        allow(UmpebcMarc).to receive(:where).with('year = ? AND updated_at >= ?', selection_year, DateTime.new(selection.year, Date.today.month, 1)).and_return([umpebc_marc])
        allow(MARC::Reader).to receive(:decode).with(umpebc_marc.mrc, external_encoding: "UTF-8", validate_encoding: true).and_return(entry)
      end

      it do
        recreate_collection_month_marc_file
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

    let(:entries) { ['.', '..'] }
    let(:filename) { collection.name + '_Complete' }
    let(:mrc_file) { instance_double(File, 'mrc_file') }
    let(:xml_file) { instance_double(File, 'xml_file') }
    let(:selection_mrc_file) { instance_double(File, 'selection_mrc_file') }
    let(:selection_xml_file) { instance_double(File, 'selection_xml_file') }

    before do
      allow(Dir).to receive(:entries).with(Dir.pwd).and_return(entries)
      allow(File).to receive(:open).with(filename + '.mrc', 'wb').and_return(mrc_file)
      allow(mrc_file).to receive(:close)
      allow(File).to receive(:open).with(filename + '.xml', 'wb').and_return(xml_file)
      allow(xml_file).to receive(:close)
    end

    it do
      recreate_collection_marc_files
      expect(program.errors).to be_empty
    end

    context 'when marc files' do
      let(:month) { Date.today.month }
      let(:entries) do
        [
          '.',
          '..',
          selection.name + '.mrc',
          selection.name + '.xml',
          selection.name + format("-%02d", month) + '.mrc',
          selection.name + format("-%02d", month) + '.xml',
          filename + '.mrc',
          filename + '.xml'
        ]
      end

      before do
        allow(File).to receive(:open).with(filename + '.mrc', 'wb').and_return(mrc_file)
        allow(mrc_file).to receive(:write).with("selection_mrc")
        allow(mrc_file).to receive(:close)
        allow(File).to receive(:open).with(filename + '.xml', 'wb').and_return(xml_file)
        allow(xml_file).to receive(:write).with("selection_xml")
        allow(xml_file).to receive(:close)
        allow(File).to receive(:open).with(selection.name + '.mrc', 'rb').and_return(selection_mrc_file)
        allow(selection_mrc_file).to receive(:read).and_return('selection_mrc')
        allow(selection_mrc_file).to receive(:close)
        allow(File).to receive(:open).with(selection.name + '.xml', 'rb').and_return(selection_xml_file)
        allow(selection_xml_file).to receive(:read).and_return('selection_xml')
        allow(selection_xml_file).to receive(:close)
      end

      it do
        recreate_collection_marc_files
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

      it do
        expect(upload_marc_files).to match_array ["#{selection_name}.xml", "#{selection_name}.mrc", "#{selection_name}-#{month}.xml", "#{selection_name}-#{month}.mrc", "Collection Metadata_Complete.xml", "Collection Metadata_Complete.mrc"]
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
    end
  end

  describe '#assemble_marc_files' do
    subject(:assemble_marc_files) { program.assemble_marc_files(collection) }

    it do
      assemble_marc_files
      expect(program.errors).to be_empty
    end

    context 'when UMPEBC Metadata folder' do
      let(:collection_name) { umpebc_metadata }
      let(:record) { instance_double(UmpebcKbart, 'record', id: 'id', updated: record_updated, verified: true) }
      let(:record_updated) { selection_updated }

      before do
        allow(UmpebcKbart).to receive(:find_by).with(name: selection.name, year: selection.year).and_return(record)
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
          allow(program).to receive(:recreate_collection_month_marc_file).with(collection).and_return("month\n")
          allow(program).to receive(:recreate_collection_marc_files).with(collection).and_return("collect\n")
          allow(record).to receive(:updated=).with(selection_updated)
          allow(record).to receive(:save!).with(no_args)
        end

        it do
          assemble_marc_files
          expect(program.errors).to be_empty
        end

        context 'when selection year updated' do # rubocop:disable RSpec/NestedGroups
          let(:selection_year) { Date.today.year }

          it do
            assemble_marc_files
            expect(program.errors).to be_empty
          end
        end
      end
    end
  end
end
