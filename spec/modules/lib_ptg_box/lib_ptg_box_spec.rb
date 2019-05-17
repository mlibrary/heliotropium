# frozen_string_literal: true

require 'rails_helper'

RSpec.describe LibPtgBox::LibPtgBox do
  describe "#product_families" do
    subject { described_class.new.product_families }

    let(:family_folder) { 'family_folder' }
    let(:product_family) { 'product_family' }

    before do
      allow(LibPtgBox::Unmarshaller::RootFolder).to receive(:family_folders).and_return([family_folder])
      allow(LibPtgBox::ProductFamily).to receive(:new).with(family_folder).and_return(product_family)
    end

    it { is_expected.to contain_exactly(product_family) }
  end
end
