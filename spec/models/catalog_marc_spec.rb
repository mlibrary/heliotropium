# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CatalogMarc, type: :model do
  subject(:catalog_marc) { create(:catalog_marc) }

  it do # rubocop:disable RSpec/ExampleLength
    expect(catalog_marc).to be_valid
    expect(catalog_marc.update?).to be true
    expect(catalog_marc.destroy?).to be true
    expect(CatalogMarc.count).to eq(1)

    catalog_marc.destroy
    expect(CatalogMarc.count).to be_zero
  end
end