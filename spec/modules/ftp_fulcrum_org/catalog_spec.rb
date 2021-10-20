# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FtpFulcrumOrg::Catalog do
  subject { catalog }

  let(:catalog) { described_class.new(publisher, sftp, pathname) }
  let(:publisher) { instance_double(FtpFulcrumOrg::Publisher, 'publisher', key: 'publisher') }
  let(:sftp) { instance_double(Net::SFTP::Session, 'sftp', dir: dir) }
  let(:dir) { instance_double(Net::SFTP::Operations::Dir, 'dir') }
  let(:pathname) { '/home/cataloging/publisher' }

  it { is_expected.to be_an_instance_of(described_class) }

  describe '#marc_files' do
    subject { catalog.marc_files }

    let(:entries) { [] }

    before { allow(dir).to receive(:entries).with(pathname).and_return(entries) }

    it { is_expected.to be_empty }

    context 'when entries' do
      let(:entries) { [marc_mrc, marc_xml] }
      let(:marc_mrc) { instance_double(Net::SFTP::Protocol::V01::Name, 'entry', name: 'marc.mrc') }
      let(:marc_xml) { instance_double(Net::SFTP::Protocol::V01::Name, 'entry', name: 'marc.xml') }
      let(:marc_mrc_file) { instance_double(MarcFile, 'marc_mrc_file') }
      let(:marc_xml_file) { instance_double(MarcFile, 'marc_xml_file') }

      before do
        allow(FtpFulcrumOrg::MarcFile).to receive(:new).with(sftp, "#{pathname}/#{marc_mrc.name}").and_return(marc_mrc_file)
        allow(FtpFulcrumOrg::MarcFile).to receive(:new).with(sftp, "#{pathname}/#{marc_xml.name}").and_return(marc_xml_file)
      end

      it { is_expected.to contain_exactly(marc_mrc_file, marc_xml_file) }
    end
  end

  context 'when marc records' do
    let(:marc) { instance_double(FtpFulcrumOrg::Marc, 'marc', doi: marc_doi) }
    let(:marc_doi) { 'marc' }
    let(:marc_records) { [] }
    let(:marc_record) { instance_double(MarcRecord, 'marc_record', id: 'id', doi: 'doi', mrc: to_marc, parsed: true) }
    let(:to_marc) { instance_double(String, 'to_marc') }
    let(:obj_marc) { instance_double(String, 'obj_marc') }

    before do
      allow(MarcRecord).to receive(:where).with(folder: publisher.key).and_return(marc_records)
      allow(MARC::Reader).to receive(:decode).with(to_marc, external_encoding: "UTF-8", validate_encoding: true).and_return(obj_marc)
      allow(FtpFulcrumOrg::Marc).to receive(:new).with(obj_marc).and_return(marc)
    end

    describe '#marc' do
      subject { catalog.marc(doi) }

      let(:doi) { 'doi' }

      it { is_expected.to be_nil }

      context 'when marc' do
        let(:marc_records) { [marc_record] }

        it { is_expected.to be_nil }

        context 'with doi' do # rubocop:disable RSpec/NestedGroups
          let(:marc_doi) { doi }

          it { is_expected.to be marc }
        end
      end
    end

    describe '#marcs' do
      subject(:marcs) { catalog.marcs }

      it { is_expected.to be_empty }

      context 'when marc' do
        let(:marc_records) { [marc_record] }

        it { is_expected.to contain_exactly(marc) }

        context 'when encoding error' do # rubocop:disable RSpec/NestedGroups
          let(:msg) { 'FtpFulcrumOrg::Catalog#marcs(id id, doi doi) Encoding::InvalidByteSequenceError' }
          let(:message) { double('message') } # rubocop:disable RSpec/VerifiedDoubles

          before do
            allow(MARC::Reader).to receive(:decode).with(to_marc, external_encoding: "UTF-8", validate_encoding: true).and_raise(Encoding::InvalidByteSequenceError)
            allow(Rails.logger).to receive(:error).with(msg)
            allow(NotifierMailer).to receive(:administrators).with('StandardError', msg).and_return(message)
            allow(message).to receive(:deliver_now)
          end

          it do
            expect(marcs).to be_empty
            expect(Rails.logger).to have_received(:error).with(msg)
            expect(message).to have_received(:deliver_now)
          end
        end
      end
    end
  end
end
