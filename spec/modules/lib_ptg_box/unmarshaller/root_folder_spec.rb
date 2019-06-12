# frozen_string_literal: true

require 'rails_helper'

RSpec.describe LibPtgBox::Unmarshaller::RootFolder do
  describe '#collections' do
    subject { described_class.sub_folders }

    let(:box_service) { instance_double(Box::Service, 'box_service') }
    let(:root_box_folder) { instance_double(Box::Folder, 'root_box_folder') }
    let(:sub_box_folder) { instance_double(Box::Folder, 'sub_box_folder') }
    let(:sub_folder) { instance_double(LibPtgBox::Unmarshaller::SubFolder, 'sub_folder') }

    before do
      allow(Box::Service).to receive(:new).and_return(box_service)
      allow(box_service).to receive(:folder).with(LibPtgBox::BOX_LIB_PTG_BOX_PATH).and_return(root_box_folder)
      allow(root_box_folder).to receive(:folders).and_return([sub_box_folder])
      allow(LibPtgBox::Unmarshaller::SubFolder).to receive(:new).with(sub_box_folder).and_return(sub_folder)
    end

    it { is_expected.to contain_exactly(sub_folder) }
  end
end
