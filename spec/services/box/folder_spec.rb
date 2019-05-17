# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Box::Folder do
  subject(:folder) { described_class.new(boxr_mash) }

  let(:boxr_mash) { instance_double(BoxrMash, 'boxr_mash') }
  let(:client) { instance_double(Boxr::Client, 'client') }

  before do
    allow(boxr_mash).to receive(:[]).with(:etag).and_return('etag')
    allow(boxr_mash).to receive(:[]).with(:id).and_return('id')
    allow(boxr_mash).to receive(:[]).with(:name).and_return('name')
    allow(boxr_mash).to receive(:[]).with(:type).and_return('folder')
    allow(Boxr::Client).to receive(:new).and_return(client)
  end

  describe '#null_folder' do
    subject(:null_folder) { described_class.null_folder }

    let(:filepath) { instance_double(String, 'filepath') }

    it { is_expected.to be_an_instance_of(Box::NullFolder) }
    it { expect(null_folder.folders).to be_empty }
    it { expect(null_folder.files).to be_empty }
    it { expect(null_folder.upload(filepath)).to be false }
  end

  describe '#folders' do
    subject { folder.folders }

    let(:folders) { [] }

    before { allow(client).to receive(:folder_items).with(boxr_mash, fields: %i[id name]).and_return(folders) }

    it { is_expected.to be_empty }

    context 'with error' do
      before { allow(client).to receive(:folder_items).with(boxr_mash, fields: %i[id name]).and_raise }

      it { is_expected.to be_empty }
    end

    context 'with folder' do
      let(:folders) { [item] }
      let(:item) { double('item', type: 'folder') } # rubocop:disable RSpec/VerifiedDoubles
      let(:box_folder) { instance_double(described_class, 'box_folder') }

      before do
        allow(described_class).to receive(:new).and_call_original
        allow(described_class).to receive(:new).with(item).and_return(box_folder)
      end

      it { is_expected.to contain_exactly(box_folder) }
    end
  end

  describe '#files' do
    subject { folder.files }

    let(:files) { [] }

    before { allow(client).to receive(:folder_items).with(boxr_mash, fields: %i[id name]).and_return(files) }

    it { is_expected.to be_empty }

    context 'with error' do
      before { allow(client).to receive(:folder_items).with(boxr_mash, fields: %i[id name]).and_raise }

      it { is_expected.to be_empty }
    end

    context 'with file' do
      let(:files) { [item] }
      let(:item) { double('item', type: 'file') } # rubocop:disable RSpec/VerifiedDoubles
      let(:box_file) { instance_double(Box::File, 'box_file') }

      before do
        allow(Box::File).to receive(:new).with(item).and_return(box_file)
      end

      it { is_expected.to contain_exactly(box_file) }
    end
  end

  describe '#upload' do
    subject { folder.upload(filepath) }

    let(:filepath) { instance_double(String, 'filepath') }

    before { allow(client).to receive(:upload_file).with(filepath, boxr_mash) }

    it { is_expected.to be true }

    context 'with error' do
      before { allow(client).to receive(:upload_file).with(filepath, boxr_mash).and_raise }

      it { is_expected.to be false }
    end
  end
end
