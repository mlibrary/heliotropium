# frozen_string_literal: true

require 'rails_helper'

require 'support/mock_boxr'

module Boxr
  MOCK_ROOT = Rails.root.join('spec', 'fixtures')

  class Client
    def initialize
      @init = true
    end

    def file_from_path(path)
      mock_client.file_from_path(File.join(MOCK_ROOT, path))
    end

    def folder_from_path(path)
      mock_client.folder_from_path(File.join(MOCK_ROOT, path))
    end

    def folder_items(folder, options)
      mock_client.folder_items(folder, options)
    end

    def download_file(file)
      mock_client.download_file(file)
    end

    def upload_file(path, folder)
      mock_client.upload_file(path, folder)
    end

    private

      def mock_client
        @mock_client ||= MockBoxr::Client.new
      end
  end
end

RSpec.describe AssembleMarcFiles::AssembleMarcFiles do
  subject(:program) { described_class.new }

  let(:lib_ptg_box) { instance_double(LibPtgBox::LibPtgBox, 'lib_ptg_box', collections: [collection]) }
  let(:collection) { instance_double(LibPtgBox::Collection, 'collection', name: collection_name, selections: [selection]) }
  let(:collection_name) { 'Collection Metadata' }
  let(:selection) { instance_double(LibPtgBox::Selection, 'selection', name: selection_name, year: selection_year, updated: selection_updated, works: [work]) }
  let(:selection_name) { "Selection_#{selection_year}" }
  let(:selection_year) { '1984' }
  let(:selection_updated) { Date.today }
  let(:work) { instance_double(LibPtgBox::Work, 'work', name: work_name, new?: work_new, marc?: work_marc, marc: marc) }
  let(:work_name) { 'Star Wars' }
  let(:work_new) { false }
  let(:work_marc) { false }
  let(:marc) { instance_double(LibPtgBox::Unmarshaller::Marc, 'marc', to_marc: 'marc', to_xml: 'xml') }
  let(:umpebc_metadata) { 'UMPEBC Metadata' }

  # before(:all) do
  #   tmp_dir = Rails.root.join('tmp')
  #   Dir.mkdir(tmp_dir) unless Dir.exist?(tmp_dir)
  #   Dir.chdir(tmp_dir)
  #   Dir.mkdir('lib_ptg_box_spec') unless Dir.exist?('lib_ptg_box_spec')
  #   Dir.chdir('lib_ptg_box_spec')
  # end

  before do
    # tmp_dir = Rails.root.join('tmp')
    # Dir.chdir(tmp_dir)
    # Dir.chdir('lib_ptg_box_spec')
    program
    allow(LibPtgBox::LibPtgBox).to receive(:new).and_return(lib_ptg_box)
    allow(selection).to receive(:collection).and_return(collection)
  end

  describe '#execute' do
    subject { program.execute }

    before do
      allow(program).to receive(:synchronize).with(lib_ptg_box).and_return("synchronize\n")
      allow(program).to receive(:assemble_marc_files).with(collection).and_return("collection\n")
    end

    it { is_expected.to eq("synchronize\n") }

    context 'when UMPEBC Metadata folder' do
      let(:collection_name) { umpebc_metadata }

      it { is_expected.to eq("synchronize\ncollection\n") }
    end
  end

  describe '#synchronize' do
    subject { program.synchronize(lib_ptg_box) }

    it { is_expected.to be_empty }

    context 'when UMPEBC Metadata folder' do
      let(:collection_name) { umpebc_metadata }
      let(:record) { instance_double(UmpebcKbart, 'record') }

      before { allow(UmpebcKbart).to receive(:find_or_create_by!).with(name: selection.name, year: selection.year).and_return(record) }

      it { is_expected.to be_empty }
    end
  end

  describe '#append_selection_month_marc_files' do
    subject { program.append_selection_month_marc_file(selection, month) }

    let(:month) { Date.today.month }
    let(:filename) { selection.name + format("-%02d", month) }
    let(:mrc_file) { instance_double(File, 'mrc_file') }
    let(:xml_file) { instance_double(File, 'xml_file') }

    before do
      allow(File).to receive(:open).with(filename + '.mrc', 'w').and_return(mrc_file)
      allow(mrc_file).to receive(:<<).with(marc.to_marc)
      allow(mrc_file).to receive(:close)
      allow(File).to receive(:open).with(filename + '.xml', 'w').and_return(xml_file)
      allow(xml_file).to receive(:<<).with(marc.to_xml)
      allow(xml_file).to receive(:<<).with("\n")
      allow(xml_file).to receive(:close)
    end

    it { is_expected.to be_empty }

    context 'when new work' do
      let(:work_new) { true }

      it { is_expected.to eq("Catalog MARC record for work '#{work.name}' in selection '#{selection.name}' in collection '#{collection.name}' is missing!\n") }

      context 'when catalog marc record' do # rubocop:disable RSpec/NestedGroups
        let(:work_marc) { true }

        it { is_expected.to eq("Catalog MARC record for work '#{work.name}' in selection '#{selection.name}' in collection '#{collection.name}' is new!\n") }
      end
    end
  end

  describe '#recreate_selection_marc_files' do
    subject { program.recreate_selection_marc_files(selection) }

    let(:filename) { selection.name }
    let(:mrc_file) { instance_double(File, 'mrc_file') }
    let(:xml_file) { instance_double(File, 'xml_file') }

    before do
      allow(File).to receive(:open).with(filename + '.mrc', 'w').and_return(mrc_file)
      allow(mrc_file).to receive(:<<).with(marc.to_marc)
      allow(mrc_file).to receive(:close)
      allow(File).to receive(:open).with(filename + '.xml', 'w').and_return(xml_file)
      allow(xml_file).to receive(:<<).with(marc.to_xml)
      allow(xml_file).to receive(:<<).with("\n")
      allow(xml_file).to receive(:close)
    end

    it { is_expected.to eq("Catalog MARC record for work '#{work.name}' in selection '#{selection.name}' in collection '#{collection.name}' is missing!\n") }

    context 'when catalog marc record' do
      let(:work_marc) { true }

      it { is_expected.to be_empty }
    end
  end

  describe '#recreate_collection_marc_files' do
    subject { program.recreate_collection_marc_files(collection) }

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

    it { is_expected.to be_empty }

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

      it { is_expected.to be_empty }
    end
  end

  describe '#replace_collection_marc_files' do
    subject { program.replace_collection_marc_files(collection) }

    let(:entries) { ['.', '..'] }

    before do
      allow(Dir).to receive(:entries).with(Dir.pwd).and_return(entries)
      allow(collection).to receive(:upload_marc_file)
    end

    it do
      is_expected.to be_empty # rubocop:disable RSpec/ImplicitSubject
      expect(collection).not_to have_received(:upload_marc_file)
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

      it do # rubocop:disable RSpec/ExampleLength
        is_expected.to be_empty # rubocop:disable RSpec/ImplicitSubject
        expect(collection).not_to have_received(:upload_marc_file).with('.')
        expect(collection).not_to have_received(:upload_marc_file).with('..')
        expect(collection).to have_received(:upload_marc_file).with(selection.name + '.mrc')
        expect(collection).to have_received(:upload_marc_file).with(selection.name + '.xml')
        expect(collection).to have_received(:upload_marc_file).with(selection.name + format("-%02d", month) + '.mrc')
        expect(collection).to have_received(:upload_marc_file).with(selection.name + format("-%02d", month) + '.xml')
        expect(collection).to have_received(:upload_marc_file).with(collection.name + '_Complete.mrc')
        expect(collection).to have_received(:upload_marc_file).with(collection.name + '_Complete.xml')
      end
    end
  end

  xdescribe '#assemble_marc_files' do
    subject { program.assemble_marc_files(collection) }

    it { is_expected.to be_empty }

    context 'when UMPEBC Metadata folder' do
      let(:collection_name) { umpebc_metadata }
      let(:record) { instance_double(UmpebcKbart, 'record', id: 'id', updated: record_updated) }
      let(:record_updated) { selection_updated }

      before { allow(UmpebcKbart).to receive(:find_by).with(name: selection.name, year: selection.year).and_return(record) }

      it { is_expected.to be_empty }

      context 'when selection updated' do # rubocop:disable RSpec/NestedGroups
        let(:month) { Date.today.month }
        let(:record_updated) { Date.yesterday }
        let(:updated) { 'updated' }

        before do
          allow(program).to receive(:append_selection_month_marc_file).with(selection, month).and_return("month\n")
          allow(program).to receive(:recreate_selection_marc_files).with(selection).and_return("select\n")
          allow(program).to receive(:recreate_collection_marc_files).with(collection).and_return("collect\n")
          allow(program).to receive(:replace_collection_marc_files).with(collection).and_return("replace\n")
          allow(record).to receive(:updated=).with(selection_updated)
          allow(record).to receive(:save).with(no_args)
        end

        it { is_expected.to eq("select\ncollect\nreplace\n") }

        context 'when selection year updated' do # rubocop:disable RSpec/NestedGroups
          let(:selection_year) { Date.today.year }

          it { is_expected.to eq("month\nselect\ncollect\nreplace\n") }
        end
      end
    end
  end
end
