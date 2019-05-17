# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Box::File do
  subject(:file) { described_class.new(boxr_mash) }

  let(:boxr_mash) { instance_double(BoxrMash, 'boxr_mash') }
  let(:client) { instance_double(Boxr::Client, 'client') }

  before do
    allow(boxr_mash).to receive(:[]).with(:etag).and_return('etag')
    allow(boxr_mash).to receive(:[]).with(:id).and_return('id')
    allow(boxr_mash).to receive(:[]).with(:name).and_return('name')
    allow(boxr_mash).to receive(:[]).with(:type).and_return('file')
    allow(Boxr::Client).to receive(:new).and_return(client)
  end

  describe '#null_file' do
    subject(:null_file) { described_class.null_file }

    it { is_expected.to be_an_instance_of(Box::NullFile) }
    it { expect(null_file.content).to be_empty }
  end

  describe '#content' do
    subject { file.content }

    let(:content) { '' }

    before { allow(client).to receive(:download_file).with(boxr_mash).and_return(content) }

    it { is_expected.to be_empty }

    context 'with error' do
      before { allow(client).to receive(:download_file).with(boxr_mash).and_raise }

      it { is_expected.to eq('RuntimeError') }
    end

    context 'with content' do
      let(:content) { 'content' }

      it { is_expected.to eq(content) }
    end
  end
end
