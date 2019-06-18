# frozen_string_literal: true

require 'rails_helper'

RSpec.describe LibPtgBox::Unmarshaller::Marc do
  subject(:marc) { described_class.new(entry) }

  let(:entry) { instance_double(MARC::Record, 'entry', fields: fields) }
  let(:fields) { [] }

  describe '#doi' do
    subject { marc.doi }

    it { is_expected.to eq("10.3998/mpub.00000000") }

    context 'with doi' do
      let(:fields) { [field] }
      let(:field) { instance_double(MARC::DataField, 'field', tag: '024', indicator1: '7', subfields: [subfield]) }
      let(:subfield) { instance_double(MARC::Subfield, 'subfield', code: 'a', value: 'doi') }

      it { is_expected.to eq('doi') }
    end
  end

  xdescribe '#to_mrc' do
    subject { marc.to_mrc }

    before { allow(entry).to receive(:to_mrc).and_return('mrc') }

    it { is_expected.to eq('') }
  end

  describe '#to_xml' do
    subject { marc.to_xml }

    before { allow(entry).to receive(:to_xml).and_return('xml') }

    it { is_expected.to eq('xml') }
  end
end
