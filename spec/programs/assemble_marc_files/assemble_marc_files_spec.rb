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

  before { program }

  describe '#execute' do
    subject { program.execute }

    let(:lib_ptg_box) { instance_double(LibPtgBox::LibPtgBox, 'lib_ptg_box', collections: [collection]) }
    let(:collection) { instance_double(LibPtgBox::Collection, 'collection', name: 'UMPEBC Metadata') }

    before do
      allow(LibPtgBox::LibPtgBox).to receive(:new).and_return(lib_ptg_box)
      allow(program).to receive(:synchronize).with(lib_ptg_box).and_return("synchronize\n")
      allow(program).to receive(:assemble_marc_files).with(collection).and_return("collection\n")
    end

    it { is_expected.to eq("synchronize\ncollection\n") }
  end

  describe '#synchronize' do
    subject { program.synchronize(lib_ptg_box) }

    # let(:lib_ptg_box) { instance_double(LibPtgBox::LibPtgBox, 'lib_ptg_box') }
    let(:lib_ptg_box) { LibPtgBox::LibPtgBox.new }

    it { is_expected.not_to be_empty }
  end

  describe '#assemble_marc_files' do
    subject { program.assemble_marc_files(collection) }

    let(:collection) { instance_double(LibPtgBox::Collection, 'collection', name: 'product_name') }

    it { is_expected.to eq(collection.name + "\n") }
  end
end
