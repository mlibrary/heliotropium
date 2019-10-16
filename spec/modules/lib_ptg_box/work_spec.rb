# frozen_string_literal: true

require 'rails_helper'

RSpec.describe LibPtgBox::Work do
  subject(:work) { described_class.new(selection, kbart) }

  let(:selection) { instance_double(LibPtgBox::Selection, 'selection', collection: collection) }
  let(:collection) { instance_double(LibPtgBox::Collection, 'collection', catalog: catalog) }
  let(:catalog) { instance_double(LibPtgBox::Catalog, 'catalog') }
  let(:kbart) { instance_double(LibPtgBox::Unmarshaller::Kbart, 'kbart', doi: 'doi', print: 'print', online: 'online', title: 'title', date: 'date') }
  let(:marc) { instance_double(LibPtgBox::Unmarshaller::Marc, 'marc') }
  let(:catalog_marc) { nil }

  before do
    allow(collection).to receive(:marc).with('doi').and_return(marc)
    allow(catalog).to receive(:marc).with('doi').and_return(catalog_marc)
  end

  describe "delegate to kbart" do
    it { expect(work.doi).to eq(kbart.doi) }
    it { expect(work.print).to eq(kbart.print) }
    it { expect(work.online).to eq(kbart.online) }
    it { expect(work.title).to eq(kbart.title) }
    it { expect(work.date).to eq(kbart.date) }
  end

  describe '#name' do
    subject { work.name }

    it { is_expected.to eq(kbart.doi) }
  end

  describe '#url' do
    subject { work.url }

    it { is_expected.to eq("https://doi.org/#{kbart.doi}") }
  end

  describe '#new?' do
    subject { work.new? }

    it { is_expected.to be false }

    context 'when marc and catalog marc' do
      let(:catalog_marc) { instance_double(LibPtgBox::Unmarshaller::Marc, 'marc') }

      it { is_expected.to be false }

      context 'when only catalog marc' do
        let(:marc) { nil }

        it { is_expected.to be true }
      end
    end
  end

  describe '#marc?' do
    subject { work.marc? }

    it { is_expected.to be false }

    context 'with marc' do
      let(:catalog_marc) { instance_double(LibPtgBox::Unmarshaller::Marc, 'marc') }

      it { is_expected.to be true }
    end
  end

  describe '#marc' do
    subject { work.marc }

    it { is_expected.to be_nil }

    context 'with marc' do
      let(:catalog_marc) { instance_double(LibPtgBox::Unmarshaller::Marc, 'marc') }

      it { is_expected.to be catalog_marc }
    end
  end
end
