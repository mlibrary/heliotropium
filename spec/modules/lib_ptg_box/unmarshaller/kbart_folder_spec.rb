# frozen_string_literal: true

require 'rails_helper'

RSpec.describe LibPtgBox::Unmarshaller::KbartFolder do
  subject(:kbart_folder) { described_class.new(box_folder) }

  let(:box_folder) { instance_double(Box::Folder, 'box_folder') }
  let(:box_files) { [] }

  before do
    allow(box_folder).to receive(:files).and_return(box_files)
  end

  describe '#kbart_files' do
    subject { kbart_folder.kbart_files }

    it { is_expected.to be_empty }

    context 'with files' do
      let(:box_files) { [box_file] }
      let(:box_file) { instance_double(Box::File, 'box_file') }
      let(:kbart_file) { instance_double(LibPtgBox::Unmarshaller::KbartFile, 'kbart_file') }

      before do
        allow(LibPtgBox::Unmarshaller::KbartFile).to receive(:new).with(box_file).and_return(kbart_file)
      end

      it { is_expected.to contain_exactly(kbart_file) }
    end
  end
end
