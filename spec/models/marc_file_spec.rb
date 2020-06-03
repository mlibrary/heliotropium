# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MarcFile, type: :model do
  subject(:marc_file) { create(:marc_file) }

  it do
    expect(marc_file).to be_valid
    expect(marc_file.update?).to be true
    expect(marc_file.destroy?).to be true
    expect(described_class.count).to eq(1)

    marc_file.destroy
    expect(described_class.count).to be_zero
  end
end
