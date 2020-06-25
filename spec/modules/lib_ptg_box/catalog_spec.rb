# frozen_string_literal: true

require 'rails_helper'

RSpec.describe LibPtgBox::Catalog do
  subject(:catalog) { described_class.new(collection, marc_folder) }

  let(:collection) { instance_double(LibPtgBox::Collection, 'collection', key: 'key') }
  let(:marc_folder) { object_double(LibPtgBox::Unmarshaller::MarcFolder.new(marc_ftp_folder), 'marc_folder') }
  let(:marc_ftp_folder) { instance_double(Ftp::Folder, 'marc_ftp_folder', name: 'folder') }
  let(:marc) { instance_double(LibPtgBox::Unmarshaller::Marc, 'marc', doi: marc_doi) }
  let(:marc_doi) { 'marc' }
  let(:marc_records) { [] }
  let(:marc_record) { instance_double(MarcRecord, 'marc_record', id: 'id', doi: 'doi', mrc: to_marc, parsed: true) }
  let(:to_marc) { instance_double(String, 'to_marc') }
  let(:obj_marc) { instance_double(String, 'obj_marc') }

  before do
    allow(MarcRecord).to receive(:where).with(folder: collection.key).and_return(marc_records)
    allow(MARC::Reader).to receive(:decode).with(to_marc, external_encoding: "UTF-8", validate_encoding: true).and_return(obj_marc)
    allow(LibPtgBox::Unmarshaller::Marc).to receive(:new).with(obj_marc).and_return(marc)
  end

  describe '#marc' do
    subject { catalog.marc(doi) }

    let(:doi) { 'doi' }

    it { is_expected.to be_nil }

    context 'when marc' do
      let(:marc_records) { [marc_record] }

      it { is_expected.to be_nil }

      context 'with doi' do
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

      context 'when encoding error' do
        let(:msg) { 'LibPtgBox::Catalog#marcs(id id, doi doi) Encoding::InvalidByteSequenceError' }
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
