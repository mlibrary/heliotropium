# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Box::Service do
  subject(:service) { described_class.new }

  let(:client) { instance_double(Boxr::Client) }

  before { allow(Boxr::Client).to receive(:new).and_return(client) }

  describe '#root_folder' do
    subject { service.root_folder }

    let(:folder) { instance_double(Box::Folder, 'folder') }

    before { allow(Box::Folder).to receive(:new).with(id: Boxr::ROOT, name: '').and_return(folder) }

    it { is_expected.to be folder }
  end

  describe '#folder' do
    subject { service.folder(path) }

    let(:path) { instance_double(String, 'path') }
    let(:boxr_mash) { instance_double(BoxrMash, 'boxr_mash') }
    let(:folder) { instance_double(Box::Folder, 'folder') }

    before do
      allow(client).to receive(:folder_from_path).with(path).and_return(boxr_mash)
      allow(Box::Folder).to receive(:new).with(boxr_mash).and_return(folder)
    end

    it { is_expected.to be folder }
  end

  describe '#file' do
    subject { service.file(path) }

    let(:path) { instance_double(String, 'path') }
    let(:boxr_mash) { instance_double(BoxrMash, 'boxr_mash') }
    let(:file) { instance_double(Box::File, 'file') }

    before do
      allow(client).to receive(:file_from_path).with(path).and_return(boxr_mash)
      allow(Box::File).to receive(:new).with(boxr_mash).and_return(file)
    end

    it { is_expected.to be file }
  end
end
