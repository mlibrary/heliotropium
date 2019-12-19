# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CatalogMarc, type: :model do
  subject(:catalog_marc) { create(:catalog_marc) }

  it do
    expect(catalog_marc).to be_valid
    expect(catalog_marc.update?).to be true
    expect(catalog_marc.destroy?).to be true
    expect(described_class.count).to eq(1)

    catalog_marc.destroy
    expect(described_class.count).to be_zero
  end
end
