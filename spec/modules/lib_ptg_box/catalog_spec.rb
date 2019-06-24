# frozen_string_literal: true

require 'rails_helper'

RSpec.describe LibPtgBox::Catalog do
  subject(:catalog) { described_class.new(selection, complete_marc_file) }

  let(:selection) { instance_double(LibPtgBox::Selection, 'selection') }
  let(:complete_marc_file) { object_double(LibPtgBox::Unmarshaller::MarcFile.new(marc_ftp_file), 'complete_marc_file', marcs: marcs) }
  let(:marc_ftp_file) { instance_double(Ftp::File, 'marc_ftp_file') }
  let(:marcs) { [] }
  let(:marc) { instance_double(LibPtgBox::Unmarshaller::Marc, 'marc', doi: marc_doi) }
  let(:marc_doi) { 'marc' }

  describe '#marc' do
    subject { catalog.marc(doi) }

    let(:doi) { 'doi' }

    it { is_expected.to be_nil }

    context 'when marc' do
      let(:marcs) { [marc] }

      it { is_expected.to be_nil }

      context 'with doi' do # rubocop:disable RSpec/NestedGroups
        let(:marc_doi) { doi }

        it { is_expected.to be marc }
      end
    end
  end

  describe '#marcs' do
    subject { catalog.marcs }

    it { is_expected.to be_empty }

    context 'when marc' do
      let(:marcs) { [marc] }

      it { is_expected.to contain_exactly(marc) }
    end
  end
end
