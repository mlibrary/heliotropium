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
end
