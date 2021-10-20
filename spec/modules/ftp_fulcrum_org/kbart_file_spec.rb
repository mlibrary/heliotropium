# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FtpFulcrumOrg::KbartFile do
  subject { kbart_file }

  let(:kbart_file) { described_class.new(sftp, pathname) }
  let(:sftp) { instance_double(Net::SFTP::Session, 'sftp', file: file_factory) }
  let(:file_factory) { instance_double(Net::SFTP::Operations::FileFactory, 'file_factory') }
  let(:file) { instance_double(Net::SFTP::Operations::File) }
  let(:pathname) { "/home/publishing/publisher/KBART/#{filename}" }
  let(:filename) { 'collection_1000_01_01.csv' }

  before do
    allow(file_factory).to receive(:open).with(pathname).and_return(file)
    allow(file).to receive(:gets).and_return(nil)
    allow(file).to receive(:close)
  end

  it { is_expected.to be_an_instance_of(described_class) }

  describe '#kbarts' do
    subject { kbart_file.kbarts }

    it { is_expected.to be_empty }

    context 'with header' do
      let(:header) { 'header' }

      before { allow(file).to receive(:gets).and_return(header, nil) }

      it { is_expected.to be_empty }

      context 'with line' do
        let(:line) { +'"kbart","csv","file"' }
        let(:kbart) { instance_double(FtpFulcrumOrg::Kbart, 'kbart') }

        before do
          allow(file).to receive(:gets).and_return(header, line, nil)
          allow(FtpFulcrumOrg::Kbart).to receive(:new).with(line).and_return(kbart)
        end

        it { is_expected.to contain_exactly(kbart) }

        context 'with lines' do # rubocop:disable RSpec/NestedGroups
          let(:another_line) { +'"another_kbart","another_csv","another_file"' }
          let(:another_kbart) { instance_double(FtpFulcrumOrg::Kbart, 'kbart') }

          before do
            allow(file).to receive(:gets).and_return(header, line, another_line, nil)
            allow(FtpFulcrumOrg::Kbart).to receive(:new).with(another_line).and_return(another_kbart)
          end

          it { is_expected.to contain_exactly(kbart, another_kbart) }
        end
      end
    end
  end
end
