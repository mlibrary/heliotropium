# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FtpFulcrumOrg::Collection do
  subject { collection }

  let(:collection) { described_class.new(publisher, sftp, pathname) }
  let(:publisher) { instance_double(FtpFulcrumOrg::Publisher, 'publisher') }
  let(:sftp) { instance_double(Net::SFTP::Session, 'sftp') }
  let(:pathname) { "/home/publishing/publisher/KBART/#{filename}" }
  let(:filename) { 'Prefix_1970_Suffix_1999-01-01.csv' }

  it { is_expected.to be_an_instance_of(described_class) }

  describe '#publisher' do
    subject { collection.publisher }

    it { is_expected.to be publisher }
  end

  describe '#name' do
    subject { collection.name }

    it { is_expected.to eq('Prefix_1970_Suffix') }
  end

  describe '#updated' do
    subject { collection.updated }

    it { is_expected.to eq(Date.parse('1999-01-01')) }
  end

  describe '#works' do
    subject { collection.works }

    let(:kbart_file) { instance_double(FtpFulcrumOrg::KbartFile, 'kbart_file', kbarts: [kbart]) }
    let(:kbart) { instance_double(FtpFulcrumOrg::Kbart, 'kbart') }
    let(:work) { instance_double(FtpFulcrumOrg::Work, 'work') }

    before do
      allow(FtpFulcrumOrg::KbartFile).to receive(:new).with(sftp, pathname).and_return(kbart_file)
      allow(FtpFulcrumOrg::Work).to receive(:new).with(collection, kbart).and_return(work)
    end

    it { is_expected.to contain_exactly(work) }
  end
end
