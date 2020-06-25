# frozen_string_literal: true

require 'rails_helper'

RSpec.describe LibPtgBox::Selection do
  subject(:selection) { described_class.new(collection, kbart_file) }

  let(:collection) { instance_double(LibPtgBox::Collection, 'collection') }
  let(:kbart_file) { object_double(LibPtgBox::Unmarshaller::KbartFile.new(kbart_ftp_file), 'kbart_file') }
  let(:kbart_ftp_file) { instance_double(Ftp::File, 'kbart_ftp_file', name: kbart_file_name) }
  let(:kbart_file_name) { 'Prefix_1970_Suffix_1999-01-01.csv' }

  before { allow(kbart_file).to receive(:name).and_return(kbart_ftp_file.name) }

  it { expect(selection.name).to eq('Prefix_1970_Suffix') }
  it { expect(selection.updated).to eq(Date.parse('1999-01-01')) }

  describe '#works' do
    subject { selection.works }

    let(:kbart) { 'kbart' }
    let(:work) { 'work' }

    before do
      allow(kbart_file).to receive(:kbarts).and_return([kbart])
      allow(LibPtgBox::Work).to receive(:new).with(selection, kbart).and_return(work)
    end

    it { is_expected.to contain_exactly(work) }
  end
end
