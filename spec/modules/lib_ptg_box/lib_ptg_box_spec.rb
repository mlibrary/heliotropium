# frozen_string_literal: true

require 'rails_helper'

RSpec.describe LibPtgBox::LibPtgBox do
  describe "#collections" do
    subject { described_class.new.collections }

    let(:sub_folder) { 'sub_folder' }
    let(:collection) { 'collection' }

    before do
      allow(LibPtgBox::Unmarshaller::RootFolder).to receive(:sub_folders).and_return([sub_folder])
      allow(LibPtgBox::Collection).to receive(:new).with(sub_folder).and_return(collection)
    end

    it { is_expected.to contain_exactly(collection) }
  end
end
