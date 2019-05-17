# frozen_string_literal: true

require 'rails_helper'

RSpec.describe LibPtgBox::Unmarshaller::RootFolder do
  describe '#family_folders' do
    subject { described_class.family_folders }

    let(:box_service) { instance_double(Box::Service, 'box_service') }
    let(:lib_ptg_box_folder) { instance_double(Box::Folder, 'lib_ptg_box_folder') }
    let(:box_family_folder) { instance_double(Box::Folder, 'box_family_folder') }
    let(:family_folder) { instance_double(LibPtgBox::Unmarshaller::FamilyFolder, 'family_folder') }

    before do
      allow(Box::Service).to receive(:new).and_return(box_service)
      allow(box_service).to receive(:folder).with(LibPtgBox::BOX_LIB_PTG_BOX_PATH).and_return(lib_ptg_box_folder)
      allow(lib_ptg_box_folder).to receive(:folders).and_return([box_family_folder])
      allow(LibPtgBox::Unmarshaller::FamilyFolder).to receive(:new).with(box_family_folder).and_return(family_folder)
    end

    it { is_expected.to contain_exactly(family_folder) }
  end
end
