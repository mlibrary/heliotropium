# frozen_string_literal: true

require 'rails_helper'

RSpec.describe LibPtgBox::Unmarshaller::MarcFolder do
  subject(:marc_folder) { described_class.new(box_folder) }

  let(:box_folder) { instance_double(Box::Folder, 'box_folder') }
  let(:box_files) { [] }

  before do
    allow(box_folder).to receive(:files).and_return(box_files)
  end

  describe '#marc_files' do
    subject { marc_folder.marc_files }

    it { is_expected.to be_empty }

    context 'with files' do
      let(:box_files) { [box_file] }
      let(:box_file) { instance_double(Box::File, 'box_file') }
      let(:marc_file) { instance_double(LibPtgBox::Unmarshaller::MarcFile, 'marc_file') }

      before do
        allow(LibPtgBox::Unmarshaller::MarcFile).to receive(:new).with(box_file).and_return(marc_file)
      end

      it { is_expected.to contain_exactly(marc_file) }
    end
  end
end
