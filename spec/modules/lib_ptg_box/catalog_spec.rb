# frozen_string_literal: true

require 'rails_helper'

RSpec.describe LibPtgBox::Catalog do
  subject { described_class.new(product, complete_marc_file) }

  let(:product) { instance_double(LibPtgBox::Product, 'product') }
  let(:complete_marc_file) { object_double(LibPtgBox::Unmarshaller::MarcFile.new(box_file), 'complete_marc_file') }
  let(:box_file) { instance_double(Box::File, 'box_file', content: '') }

  before do
    allow(complete_marc_file).to receive(:content).and_return(box_file.content)
  end

  it { is_expected.not_to be_nil }
end
