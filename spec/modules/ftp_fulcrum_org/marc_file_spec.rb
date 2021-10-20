# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FtpFulcrumOrg::MarcFile do
  subject { marc_file }

  let(:marc_file) { described_class.new(sftp, pathname) }
  let(:pathname) { '/home/cataloging/publisher/marc.xml' }
  let(:sftp) { instance_double(Net::SFTP::Session, 'sftp', file: file_factory) }
  let(:file_factory) { instance_double(Net::SFTP::Operations::FileFactory, 'file_factory') }
  let(:file) { instance_double(Net::SFTP::Operations::File, 'file', stat: stat, read: content) }
  let(:stat) { instance_double(Net::SFTP::Protocol::V01::Attributes, 'stat', mtime: mtime) }
  let(:mtime) { Time.at(0) }
  let(:content) { +'content' }

  before do
    allow(file_factory).to receive(:open).with(pathname).and_return(file)
    allow(file).to receive(:close)
  end

  it { is_expected.to be_an_instance_of(described_class) }

  describe '#name' do
    subject { marc_file.name }

    it { is_expected.to eq ::File.basename(pathname) }
  end

  describe '#updated' do
    subject { marc_file.updated }

    it { is_expected.to eq mtime.to_date }
  end

  describe '#content' do
    subject { marc_file.content }

    it { is_expected.to eq content }
  end
end
