# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MarcRecord, type: :model do
  subject(:marc_record) { create(:marc_record) }

  it do
    expect(marc_record).to be_valid
    expect(marc_record.update?).to be true
    expect(marc_record.destroy?).to be true
    expect(described_class.count).to eq(1)

    marc_record.destroy
    expect(described_class.count).to be_zero
  end
end
