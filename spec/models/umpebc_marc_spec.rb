# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UmpebcMarc, type: :model do
  subject(:umpebc_marc) { create(:umpebc_marc) }

  it do
    expect(umpebc_marc).to be_valid
    expect(umpebc_marc.update?).to be true
    expect(umpebc_marc.destroy?).to be true
    expect(UmpebcMarc.count).to eq(1)

    umpebc_marc.destroy
    expect(UmpebcMarc.count).to be_zero
  end
end
