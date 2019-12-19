# frozen_string_literal: true

require 'rails_helper'

RSpec.describe LibPtgBox::Unmarshaller::SubFolder do
  subject(:sub_folder) { described_class.new(sub_ftp_folder) }

  let(:sub_ftp_folder) { instance_double(Ftp::Folder, 'sub_ftp_folder') }
  let(:ftp_folders) { [] }

  before do
    allow(sub_ftp_folder).to receive(:folders).and_return(ftp_folders)
  end

  describe '#kbart_folder' do
    subject(:kbart_folder) { sub_folder.kbart_folder }

    it { expect(kbart_folder.name).to eq('NullFolder') }

    context 'with kbart folder' do
      let(:ftp_folders) { [kbart_ftp_folder] }
      let(:kbart_ftp_folder) { instance_double(Ftp::Folder, 'kbart_ftp_folder', name: 'kbart') }

      it { expect(kbart_folder.name).to eq('kbart') }
    end
  end

  describe '#marc_folder' do
    subject(:marc_folder) { sub_folder.marc_folder }

    it { expect(marc_folder.name).to eq('NullFolder') }

    context 'with marc folder' do
      let(:ftp_folders) { [marc_ftp_folder] }
      let(:marc_ftp_folder) { instance_double(Ftp::Folder, 'marc_ftp_folder', name: 'marc') }

      it { expect(marc_folder.name).to eq('marc') }
    end
  end

  describe '#upload_folder' do
    subject(:upload_folder) { sub_folder.upload_folder }

    it { expect(upload_folder.name).to eq('NullFolder') }

    context 'with upload folder' do
      let(:ftp_folders) { [upload_ftp_folder] }
      let(:upload_ftp_folder) { instance_double(Ftp::Folder, 'upload_ftp_folder', name: 'dev') }

      it { expect(upload_folder.name).to eq('dev') }
    end
  end

  describe '#cataloging_marc_folder' do
    subject(:cataloging_marc_folder) { sub_folder.cataloging_marc_folder }

    it { expect(cataloging_marc_folder.name).to eq('NullFolder') }

    context 'with cataloging marc folder' do
      let(:ftp_folders) { [cataloging_marc_ftp_folder] }
      let(:cataloging_marc_ftp_folder) { instance_double(Ftp::Folder, 'cataloging_marc_ftp_folder', name: 'cataloging') }

      it { expect(cataloging_marc_folder.name).to eq('cataloging') }
    end
  end
end
