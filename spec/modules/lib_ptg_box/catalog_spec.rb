# frozen_string_literal: true

require 'rails_helper'

RSpec.describe LibPtgBox::Catalog do
  subject(:catalog) { described_class.new(product, complete_marc_file) }

  let(:product) { instance_double(LibPtgBox::Product, 'product') }
  let(:complete_marc_file) { object_double(LibPtgBox::Unmarshaller::MarcFile.new(marc_box_file), 'complete_marc_file') }
  let(:marc_box_file) { instance_double(Box::File, 'marc_box_file', content: content) }
  let(:content) { instance_double(String, 'content') }
  let(:string_io) { instance_double(StringIO, 'string_io') }
  let(:reader) { instance_double(MARC::XMLReader, 'XMLReader') }
  let(:entries) { [] }

  before do
    allow(complete_marc_file).to receive(:content).and_return(marc_box_file.content)
    allow(StringIO).to receive(:new).with(content).and_return(string_io)
    allow(MARC::XMLReader).to receive(:new).with(string_io).and_return(reader)
    allow(reader).to receive(:entries).and_return(entries)
  end

  describe 'marc' do
    subject { catalog.marc(doi) }

    let(:doi) { 'doi' }

    it { is_expected.to be_nil }

    context 'with doi' do
      let(:entries) { [entry] }
      let(:entry) { instance_double(MARC::Record, 'entry') }
      let(:marc) { instance_double(LibPtgBox::Unmarshaller::Marc, 'marc', doi: doi) }

      before { allow(LibPtgBox::Unmarshaller::Marc).to receive(:new).with(entry).and_return(marc) }

      it { is_expected.to be marc }
    end
  end
end
