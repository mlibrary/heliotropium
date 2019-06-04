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

RSpec.describe AssembleMarcFiles do
  subject(:assemble_marc_files) { described_class.new }

  describe '#run' do
    subject { assemble_marc_files.run }

    it { is_expected.to be_nil }
  end
end
