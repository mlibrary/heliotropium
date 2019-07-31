# frozen_string_literal: true

require 'rails_helper'

RSpec.describe LibPtgBox::Catalog do
  subject(:catalog) { described_class.new(selection, marc_folder) }

  let(:selection) { instance_double(LibPtgBox::Selection, 'selection') }
  let(:marc_folder) { object_double(LibPtgBox::Unmarshaller::MarcFolder.new(marc_ftp_folder), 'marc_folder', marc_files: marc_files) }
  let(:marc_ftp_folder) { instance_double(Ftp::Folder, 'marc_ftp_folder') }
  let(:marc_files) { [] }
  let(:marc_file) { object_double(LibPtgBox::Unmarshaller::MarcFile.new(marc_ftp_file), 'marc_file', marcs: marcs) }
  let(:marc_ftp_file) { instance_double(Ftp::File, 'marc_ftp_file', name: 'file.mrc') }
  let(:marcs) { [] }
  let(:marc) { instance_double(LibPtgBox::Unmarshaller::Marc, 'marc', doi: marc_doi) }
  let(:marc_doi) { 'marc' }

  before { allow(marc_file).to receive(:name).and_return(marc_ftp_file.name) }

  describe '#marc' do
    subject { catalog.marc(doi) }

    let(:doi) { 'doi' }

    it { is_expected.to be_nil }

    context 'when marc' do
      let(:marc_files) { [marc_file] }
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
      let(:marc_files) { [marc_file] }
      let(:marcs) { [marc] }

      it { is_expected.to contain_exactly(marc) }
    end
  end
end
