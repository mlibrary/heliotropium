# frozen_string_literal: true

require 'rails_helper'

RSpec.describe LibPtgBox::Catalog do
  subject(:catalog) { described_class.new(selection, marc_folder) }

  let(:selection) { instance_double(LibPtgBox::Selection, 'selection') }
  let(:marc_folder) { object_double(LibPtgBox::Unmarshaller::MarcFolder.new(marc_ftp_folder), 'marc_folder') }
  let(:marc_ftp_folder) { instance_double(Ftp::Folder, 'marc_ftp_folder', name: 'folder') }
  let(:marc) { instance_double(LibPtgBox::Unmarshaller::Marc, 'marc', to_marc: 'to_marc', doi: marc_doi) }
  let(:marc_doi) { 'marc' }
  let(:catalog_marcs) { [] }
  let(:catalog_marc) { instance_double(CatalogMarc, 'catalog_marc', raw: raw_marc, parsed: true, replaced: false) }
  let(:raw_marc) { instance_double(String, 'raw_marc') }
  let(:obj_marc) { instance_double(String, 'obj_marc') }

  before do
    allow(CatalogMarc).to receive(:all).and_return(catalog_marcs)
    allow(MARC::Reader).to receive(:decode).with(raw_marc, external_encoding: "UTF-8", validate_encoding: true).and_return(obj_marc)
    allow(LibPtgBox::Unmarshaller::Marc).to receive(:new).with(obj_marc).and_return(marc)
  end

  describe '#marc' do
    subject { catalog.marc(doi) }

    let(:doi) { 'doi' }

    it { is_expected.to be_nil }

    context 'when marc' do
      let(:catalog_marcs) { [catalog_marc] }

      it { is_expected.to be_nil }

      context 'with doi' do
        let(:marc_doi) { doi }

        it { is_expected.to be marc }
      end
    end
  end

  describe '#marcs' do
    subject { catalog.marcs }

    it { is_expected.to be_empty }

    context 'when marc' do
      let(:catalog_marcs) { [catalog_marc] }

      it { is_expected.to contain_exactly(marc) }
    end
  end
end
