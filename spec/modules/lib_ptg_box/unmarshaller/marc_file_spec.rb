# frozen_string_literal: true

require 'rails_helper'

RSpec.describe LibPtgBox::Unmarshaller::MarcFile do
  subject(:marc_file) { described_class.new(box_file) }

  let(:box_file) { instance_double(Box::File, 'box_file', content: content) }
  let(:content) { '' }

  describe '#marcs' do
    subject { marc_file.marcs }

    it { is_expected.to be_empty }

    context 'with marcs' do
      let(:content) do
        <<~LINES
          marc xml record
        LINES
      end

      let(:marc) { instance_double(LibPtgBox::Unmarshaller::Marc, 'marc') }

      before do
        allow(LibPtgBox::Unmarshaller::Marc).to receive(:new).with("marc xml record\n").and_return(marc)
      end

      it { is_expected.to be_empty }
      xit { is_expected.to contain_exactly(marc) }
    end
  end
end
