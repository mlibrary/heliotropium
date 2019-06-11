# frozen_string_literal: true

require 'rails_helper'

RSpec.describe LibPtgBox::Unmarshaller::RootFolder do
  describe '#sub_folders' do
    subject { described_class.sub_folders }

    let(:box_service) { instance_double(Box::Service, 'box_service') }
    let(:lib_ptg_box_folder) { instance_double(Box::Folder, 'lib_ptg_box_folder') }
    let(:box_sub_folder) { instance_double(Box::Folder, 'box_sub_folder') }
    let(:sub_folder) { instance_double(LibPtgBox::Unmarshaller::SubFolder, 'sub_folder') }

    before do
      allow(Box::Service).to receive(:new).and_return(box_service)
      allow(box_service).to receive(:folder).with(LibPtgBox::BOX_LIB_PTG_BOX_PATH).and_return(lib_ptg_box_folder)
      allow(lib_ptg_box_folder).to receive(:folders).and_return([box_sub_folder])
      allow(LibPtgBox::Unmarshaller::SubFolder).to receive(:new).with(box_sub_folder).and_return(sub_folder)
    end

    it { is_expected.to contain_exactly(sub_folder) }
  end
end
