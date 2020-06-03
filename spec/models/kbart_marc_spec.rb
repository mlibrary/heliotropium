# frozen_string_literal: true

require 'rails_helper'

RSpec.describe KbartMarc, type: :model do
  subject(:kbart_marc) { create(:kbart_marc) }

  it do
    expect(kbart_marc).to be_valid
    expect(kbart_marc.update?).to be true
    expect(kbart_marc.destroy?).to be true
    expect(described_class.count).to eq(1)

    kbart_marc.destroy
    expect(described_class.count).to be_zero
  end
end
