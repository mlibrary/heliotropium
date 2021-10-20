# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FtpFulcrumOrg::Publisher do
  subject { publisher }

  let(:publisher) { described_class.new(sftp, publisher_hash) }
  let(:sftp) { instance_double(Net::SFTP::Session, 'sftp', dir: dir) }
  let(:dir) { instance_double(Net::SFTP::Operations::Dir, 'dir') }
  let(:publisher_hash) { Settings.ftp_fulcrum_org.publishers.first }

  it { is_expected.to be_an_instance_of(described_class) }

  describe '#key' do
    subject { publisher.key }

    it { is_expected.to eq publisher_hash.key }
  end

  describe '#name' do
    subject { publisher.name }

    it { is_expected.to eq publisher_hash.name }
  end

  describe '#mailers' do
    subject { publisher.mailers }

    it { is_expected.to eq publisher_hash.mailers }
  end

  describe '#collections' do
    subject { publisher.collections }

    let(:pathname) { File.join(Settings.ftp_fulcrum_org.home, Settings.ftp_fulcrum_org.pub, publisher_hash.pub, Settings.ftp_fulcrum_org.kbart) }
    let(:entries) { [] }

    before { allow(dir).to receive(:entries).with(pathname).and_return(entries) }

    it { is_expected.to be_empty }

    context 'when entry' do
      let(:entries) { [entry] }
      let(:entry) { instance_double(Net::SFTP::Protocol::V01::Name, 'entry', name: name) }
      let(:name) { 'kbart.csv' }
      let(:collection) { instance_double(FtpFulcrumOrg::Collection, 'collection') }

      before { allow(FtpFulcrumOrg::Collection).to receive(:new).with(publisher, sftp, File.join(pathname, entry.name)).and_return(collection) }

      it { is_expected.to contain_exactly(collection) }

      context 'when entries' do
        let(:entries) { [entry, another_entry] }
        let(:another_entry) { instance_double(Net::SFTP::Protocol::V01::Name, 'another_entry', name: another_name) }
        let(:another_name) { 'another_kbart.csv' }
        let(:another_collection) { instance_double(FtpFulcrumOrg::Collection, 'another_collection') }

        before { allow(FtpFulcrumOrg::Collection).to receive(:new).with(publisher, sftp, File.join(pathname, another_entry.name)).and_return(another_collection) }

        it { is_expected.to contain_exactly(collection, another_collection) }
      end
    end
  end

  describe '#upload_marc_file' do
    subject(:upload_marc_file) { publisher.upload_marc_file(filename) }

    let(:filename) { 'filename.txt' }
    let(:pathname) { File.join(Settings.ftp_fulcrum_org.home, Settings.ftp_fulcrum_org.pub, publisher_hash.pub, Settings.ftp_fulcrum_org.marc) }

    before { allow(sftp).to receive(:upload!).with(filename, File.join(pathname, filename)) }

    it do
      upload_marc_file
      expect(sftp).to have_received(:upload!).with(filename, File.join(pathname, filename))
    end
  end

  describe '#catalog' do
    subject { publisher.catalog }

    let(:catalog) { 'catalog' }
    let(:pathname) { File.join(Settings.ftp_fulcrum_org.home, Settings.ftp_fulcrum_org.cat, publisher_hash.cat) }

    before { allow(FtpFulcrumOrg::Catalog).to receive(:new).with(publisher, sftp, pathname).and_return(catalog) }

    it { is_expected.to be catalog }
  end
end
