# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FtpFulcrumOrg::Work do
  subject { work }

  let(:work) { described_class.new(collection, kbart) }
  let(:collection) { instance_double(FtpFulcrumOrg::Collection, 'collection', publisher: publisher) }
  let(:publisher) { instance_double(FtpFulcrumOrg::Publisher, 'publisher', catalog: catalog) }
  let(:catalog) { instance_double(FtpFulcrumOrg::Catalog, 'catalog') }
  let(:kbart) { instance_double(FtpFulcrumOrg::Kbart, 'kbart', doi: 'doi', print: 'print', online: 'online', title: 'title', date: 'date') }
  let(:marc) { nil }

  before { allow(catalog).to receive(:marc).with(kbart.doi).and_return(marc) }

  it { is_expected.to be_an_instance_of(described_class) }

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

  describe '#marc?' do
    subject { work.marc? }

    it { is_expected.to be false }

    context 'when marc' do
      let(:marc) { instance_double(FtpFulcrumOrg::Marc, 'marc') }

      it { is_expected.to be true }
    end
  end

  describe '#marc' do
    subject { work.marc }

    it { is_expected.to be_nil }

    context 'when marc' do
      let(:marc) { instance_double(FtpFulcrumOrg::Marc, 'marc') }

      before { allow(catalog).to receive(:marc).with('doi').and_return(marc) }

      it { is_expected.to be marc }
    end
  end
end
