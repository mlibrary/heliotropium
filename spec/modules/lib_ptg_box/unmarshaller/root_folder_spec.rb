# frozen_string_literal: true

require 'rails_helper'

require 'net/ftp'

RSpec.describe LibPtgBox::Unmarshaller::RootFolder do
  describe '#collections' do
    subject(:sub_folders) { described_class.sub_folders }

    let(:ftp) { instance_double(Net::FTP, 'ftp') }
    let(:entries) { [] }

    before do
      allow(Net::FTP).to receive(:open).with(Settings.lib_ptg_box.ftp, username: Settings.lib_ptg_box.user, password: Settings.lib_ptg_box.password, ssl: true).and_yield(ftp)
      allow(ftp).to receive(:chdir).with(Settings.lib_ptg_box.root)
      allow(ftp).to receive(:mlsd).and_return(entries)
    end

    it { is_expected.to be_empty }

    context 'with folder' do
      let(:entries) { [entry] }
      let(:entry) { double('entry', pathname: 'folder', facts: { 'type' => 'dir' }) } # rubocop:disable RSpec/VerifiedDoubles

      it { expect(sub_folders.length).to eq(1) }
      it { expect(sub_folders.first).to be_an_instance_of(LibPtgBox::Unmarshaller::SubFolder) }
      it { expect(sub_folders.first.name).to eq(entry.pathname) }
    end

    context 'with file' do
      let(:entries) { [entry] }
      let(:entry) { double('entry', pathname: 'file', facts: { 'type' => 'file' }) } # rubocop:disable RSpec/VerifiedDoubles

      it { is_expected.to be_empty }
    end
  end
end
