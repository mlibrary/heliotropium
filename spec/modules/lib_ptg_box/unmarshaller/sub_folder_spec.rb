# frozen_string_literal: true

require 'rails_helper'

RSpec.describe LibPtgBox::Unmarshaller::SubFolder do
  subject(:sub_folder) { described_class.new(sub_ftp_folder) }

  let(:sub_ftp_folder) { instance_double(Ftp::Folder, 'sub_ftp_folder') }
  let(:cataloging_marc_ftp_folder) { instance_double(Ftp::Folder, 'cataloging_marc_ftp_folder', name: 'MARC from Cataloging') }
  let(:marc_ftp_folder) { instance_double(Ftp::Folder, 'marc_ftp_folder', name: 'UMPEBC MARC') }
  let(:kbart_ftp_folder) { instance_double(Ftp::Folder, 'kbart_ftp_folder', name: 'UMPEBC KBART') }
  let(:fixes_ftp_folder) { instance_double(Ftp::Folder, 'upload_ftp_folder', name: 'OCLC_fixes') }
  let(:all_ftp_folders) { [cataloging_marc_ftp_folder, marc_ftp_folder, kbart_ftp_folder, fixes_ftp_folder] }
  let(:ftp_folders) { [] }

  before do
    allow(sub_ftp_folder).to receive(:folders).and_return(ftp_folders)
  end

  describe '#kbart_folder' do
    subject(:kbart_folder) { sub_folder.kbart_folder }

    it { expect(kbart_folder.name).to eq('NullFolder') }

    context 'with all foldesr' do
      let(:ftp_folders) { all_ftp_folders }

      it { expect(kbart_folder.name).to eq(kbart_ftp_folder.name) }
    end
  end

  describe '#marc_folder' do
    subject(:marc_folder) { sub_folder.marc_folder }

    it { expect(marc_folder.name).to eq('NullFolder') }

    context 'with all folders' do
      let(:ftp_folders) { all_ftp_folders }

      it { expect(marc_folder.name).to eq(marc_ftp_folder.name) }
    end
  end

  describe '#upload_folder' do
    subject(:upload_folder) { sub_folder.upload_folder }

    it { expect(upload_folder.name).to eq('NullFolder') }

    context 'with all folders' do
      let(:ftp_folders) { all_ftp_folders }

      it { expect(upload_folder.name).to eq(marc_ftp_folder.name) }
    end
  end

  describe '#cataloging_marc_folder' do
    subject(:cataloging_marc_folder) { sub_folder.cataloging_marc_folder }

    it { expect(cataloging_marc_folder.name).to eq('NullFolder') }

    context 'with all folders' do
      let(:ftp_folders) { all_ftp_folders }

      it { expect(cataloging_marc_folder.name).to eq(cataloging_marc_ftp_folder.name) }
    end
  end
end
