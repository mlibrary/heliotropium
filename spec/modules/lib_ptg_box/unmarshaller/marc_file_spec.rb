# frozen_string_literal: true

require 'rails_helper'

RSpec.describe LibPtgBox::Unmarshaller::MarcFile do
  subject(:marc_file) { described_class.new(ftp_file) }

  let(:ftp_file) { instance_double(Ftp::File, 'ftp_file', content: content) }
  let(:content) { instance_double(String, 'content', encoding: 'encoding', valid_encoding?: true) }
  let(:string_io) { instance_double(StringIO, 'string_io') }
  let(:reader) { instance_double(MARC::XMLReader, 'reader') }
  let(:entries) { [] }

  before do
    allow(content).to receive(:force_encoding).with('UTF-8').and_return(content)
    allow(content).to receive(:encode).with('UTF-8').and_return(content)
    allow(StringIO).to receive(:new).with(content).and_return(string_io)
    allow(MARC::XMLReader).to receive(:new).with(string_io).and_return(reader)
    allow(reader).to receive(:entries).and_return(entries)
  end

  describe '#marcs' do
    subject { marc_file.marcs }

    it { is_expected.to be_empty }

    context 'with marcs' do
      let(:entries) { [entry] }
      let(:entry) { instance_double(String, 'entry') }
      let(:marc) { instance_double(LibPtgBox::Unmarshaller::Marc, 'marc') }

      before do
        allow(LibPtgBox::Unmarshaller::Marc).to receive(:new).with(entry).and_return(marc)
      end

      it { is_expected.to contain_exactly(marc) }
    end
  end
end
