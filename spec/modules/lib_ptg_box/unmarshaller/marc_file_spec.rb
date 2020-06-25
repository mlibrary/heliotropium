# frozen_string_literal: true

require 'rails_helper'

RSpec.describe LibPtgBox::Unmarshaller::MarcFile do
  subject(:marc_file) { described_class.new(ftp_file) }

  let(:ftp_file) { instance_double(Ftp::File, 'ftp_file', name: 'filename', content: content) }
  let(:content) { instance_double(String, 'content', encoding: 'encoding', valid_encoding?: true) }
  let(:string_io) { instance_double(StringIO, 'string_io') }
  let(:reader) { instance_double(MARC::XMLReader, 'reader') }
  let(:entries) { [] }

  before do
    # allow(ftp_file).to receive(:name).and_return('filename')
    allow(content).to receive(:force_encoding).with('UTF-8').and_return(content)
    allow(content).to receive(:encode).with('UTF-8').and_return(content)
    allow(StringIO).to receive(:new).with(content).and_return(string_io)
    allow(MARC::Reader).to receive(:new).with(string_io).and_return(reader)
    allow(reader).to receive(:entries).and_return(entries)
  end

  describe '#marcs' do
    subject(:marcs) { marc_file.marcs }

    it { is_expected.to be_empty }

    context 'with marcs' do
      let(:entries) { [entry] }
      let(:entry) { instance_double(String, 'entry', to_s: 'entry') }
      let(:marc) { instance_double(LibPtgBox::Unmarshaller::Marc, 'marc') }

      before do
        allow(LibPtgBox::Unmarshaller::Marc).to receive(:new).with(entry).and_return(marc)
      end

      it { is_expected.to contain_exactly(marc) }

      context 'with unmarshaller error' do
        let(:msg) { 'LibPtgBox::Unmarshaller::MarcFile(filename)#marcs(entry) StandardError' }
        let(:message) { double('message') } # rubocop:disable RSpec/VerifiedDoubles

        before do
          allow(LibPtgBox::Unmarshaller::Marc).to receive(:new).with(entry).and_raise(StandardError)
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

      context 'with encoding error' do
        let(:utf_8_content) { instance_double(String, 'utf_8_content') }
        let(:utf_8_encoding) { instance_double(String, 'utf_8_encoding') }
        let(:msg) { 'LibPtgBox::Unmarshaller::MarcFile(filename)#marcs invalid UTF-8 encoding!!!' }
        let(:message) { double('message') } # rubocop:disable RSpec/VerifiedDoubles

        before do
          allow(content).to receive(:force_encoding).with('UTF-8').and_return(utf_8_content)
          allow(utf_8_content).to receive(:encoding).and_return(nil)
          allow(utf_8_content).to receive(:valid_encoding?).and_return(false)
          allow(utf_8_content).to receive(:encode).with('UTF-8', 'binary', invalid: :replace, undef: :replace, replace: '').and_return(utf_8_content)
          allow(StringIO).to receive(:new).with(utf_8_content).and_return(string_io)
          allow(Rails.logger).to receive(:error).with(msg)
          allow(NotifierMailer).to receive(:administrators).with('Invalid UTF-8 encoding!!!', msg).and_return(message)
          allow(message).to receive(:deliver_now)
        end

        it do
          expect(marcs).to contain_exactly(marc)
          expect(Rails.logger).to have_received(:error).with(msg)
          expect(message).to have_received(:deliver_now)
        end
      end
    end
  end
end
