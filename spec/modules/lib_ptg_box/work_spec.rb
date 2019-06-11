# frozen_string_literal: true

require 'rails_helper'

RSpec.describe LibPtgBox::Work do
  subject(:work) { described_class.new(selection, kbart) }

  let(:selection) { instance_double(LibPtgBox::Selection, 'selection', collection: collection) }
  let(:collection) { instance_double(LibPtgBox::Collection, 'collection', catalog: catalog) }
  let(:catalog) { instance_double(LibPtgBox::Catalog, 'catalog') }
  let(:kbart) { instance_double(LibPtgBox::Unmarshaller::Kbart, 'kbart', doi: 'doi') }
  let(:marc) { nil }

  before { allow(catalog).to receive(:marc).with('doi').and_return(marc) }

  describe 'marc?' do
    subject { work.marc? }

    it { is_expected.to be false }

    context 'with marc' do
      let(:marc) { instance_double(LibPtgBox::Unmarshaller::Marc, 'marc') }

      it { is_expected.to be true }
    end
  end

  describe 'marc' do
    subject { work.marc }

    it { is_expected.to be_nil }

    context 'with marc' do
      let(:marc) { instance_double(LibPtgBox::Unmarshaller::Marc, 'marc') }

      it { is_expected.to be marc }
    end
  end
end
