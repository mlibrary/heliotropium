# frozen_string_literal: true

require 'rails_helper'

RSpec.describe LibPtgBox::Unmarshaller::KbartFile do
  subject(:kbart_file) { described_class.new(box_file) }

  let(:box_file) { instance_double(Box::File, 'box_file', content: content) }
  let(:content) { '' }

  describe '#kbarts' do
    subject { kbart_file.kbarts }

    it { is_expected.to be_empty }

    context 'with kbarts' do
      let(:content) do
        <<~LINES
          headers
          "kbart","csv","file"
        LINES
      end

      let(:kbart) { instance_double(LibPtgBox::Unmarshaller::Kbart, 'kbart') }

      before do
        allow(LibPtgBox::Unmarshaller::Kbart).to receive(:new).with("\"kbart\",\"csv\",\"file\"\n").and_return(kbart)
      end

      it { is_expected.to contain_exactly(kbart) }
    end
  end
end
