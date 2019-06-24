# frozen_string_literal: true

require 'rails_helper'

RSpec.describe LibPtgBox::Unmarshaller::KbartFolder do
  subject(:kbart_folder) { described_class.new(ftp_folder) }

  let(:ftp_folder) { instance_double(Ftp::Folder, 'ftp_folder') }
  let(:ftp_files) { [] }

  before do
    allow(ftp_folder).to receive(:files).and_return(ftp_files)
  end

  describe '#kbart_files' do
    subject { kbart_folder.kbart_files }

    it { is_expected.to be_empty }

    context 'with files' do
      let(:ftp_files) { [ftp_file] }
      let(:ftp_file) { instance_double(Ftp::File, 'ftp_file') }
      let(:kbart_file) { instance_double(LibPtgBox::Unmarshaller::KbartFile, 'kbart_file') }

      before do
        allow(LibPtgBox::Unmarshaller::KbartFile).to receive(:new).with(ftp_file).and_return(kbart_file)
      end

      it { is_expected.to contain_exactly(kbart_file) }
    end
  end
end
