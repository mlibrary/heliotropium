# frozen_string_literal: true

require 'rails_helper'

RSpec.describe LibPtgBox::Unmarshaller::MarcFolder do
  subject(:marc_folder) { described_class.new(ftp_folder) }

  let(:ftp_folder) { instance_double(Ftp::Folder, 'ftp_folder') }
  let(:ftp_files) { [] }

  before do
    allow(ftp_folder).to receive(:files).and_return(ftp_files)
  end

  describe '#marc_files' do
    subject { marc_folder.marc_files }

    it { is_expected.to be_empty }

    context 'with files' do
      let(:ftp_files) { [ftp_file] }
      let(:ftp_file) { instance_double(Ftp::File, 'ftp_file') }
      let(:marc_file) { instance_double(LibPtgBox::Unmarshaller::MarcFile, 'marc_file') }

      before do
        allow(LibPtgBox::Unmarshaller::MarcFile).to receive(:new).with(ftp_file).and_return(marc_file)
      end

      it { is_expected.to contain_exactly(marc_file) }
    end
  end
end
