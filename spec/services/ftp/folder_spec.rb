# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Ftp::Folder do
  subject(:folder) { described_class.new(service, pathname) }

  let(:service) { instance_double(Ftp::Service, 'service', host: 'host', user: 'user', password: 'password') }
  let(:pathname) { File.join(parent, child) }
  let(:parent) { 'parent' }
  let(:child) { 'child' }
  let(:ftp) { instance_double(Net::FTP, 'ftp') }
  let(:entries) { [] }

  before do
    allow(Net::FTP).to receive(:open).with(service.host, username: service.user, password: service.password, ssl: true).and_yield(ftp)
    allow(ftp).to receive(:chdir).with(parent)
    allow(ftp).to receive(:chdir).with(child)
    allow(ftp).to receive(:mlsd).and_return(entries)
  end

  describe '#null_folder' do
    subject(:null_folder) { described_class.null_folder }

    let(:filename) { instance_double(String, 'filename') }

    it { is_expected.to be_an_instance_of(Ftp::NullFolder) }
    it { expect(null_folder.folders).to be_empty }
    it { expect(null_folder.files).to be_empty }
    it { expect(null_folder.upload(filename)).to be false }
  end

  describe '#folders' do
    subject(:subfolders) { folder.folders }

    it { is_expected.to be_empty }

    context 'with chdir error' do
      before { allow(ftp).to receive(:chdir).with(parent).and_raise(RuntimeError) }

      it { is_expected.to be_empty }
    end

    context 'with folder' do
      let(:entries) { [entry] }
      let(:entry) { double('entry', pathname: 'folder', facts: { 'type' => 'dir' }) } # rubocop:disable RSpec/VerifiedDoubles

      it { expect(subfolders.length).to eq(1) }
      it { expect(subfolders.first).to be_an_instance_of(described_class) }
      it { expect(subfolders.first.name).to eq(entry.pathname) }
    end

    context 'with file' do
      let(:entries) { [entry] }
      let(:entry) { double('entry', pathname: 'file', facts: { 'type' => 'file' }) } # rubocop:disable RSpec/VerifiedDoubles

      it { is_expected.to be_empty }
    end
  end

  describe '#files' do
    subject(:files) { folder.files }

    it { is_expected.to be_empty }

    context 'with chdir error' do
      before { allow(ftp).to receive(:chdir).with(child).and_raise(RuntimeError) }

      it { is_expected.to be_empty }
    end

    context 'with folder' do
      let(:entries) { [entry] }
      let(:entry) { double('entry', pathname: 'folder', facts: { 'type' => 'dir' }) } # rubocop:disable RSpec/VerifiedDoubles

      it { is_expected.to be_empty }
    end

    context 'with file' do
      let(:entries) { [entry] }
      let(:entry) { double('entry', pathname: 'file', facts: { 'type' => 'file' }) } # rubocop:disable RSpec/VerifiedDoubles

      it { expect(files.length).to eq(1) }
      it { expect(files.first).to be_an_instance_of(Ftp::File) }
      it { expect(files.first.name).to eq(entry.pathname) }
    end
  end

  describe '#upload' do
    subject { folder.upload(filename) }

    let(:filename) { instance_double(String, 'filename') }
    let(:file) { instance_double(File, 'file') }

    before do
      allow(::File).to receive(:open).with(filename).and_yield(file)
      allow(ftp).to receive(:putbinaryfile).with(file)
    end

    it { is_expected.to be true }

    context 'with error' do
      before { allow(ftp).to receive(:putbinaryfile).with(file).and_raise }

      it { is_expected.to be false }
    end
  end
end
