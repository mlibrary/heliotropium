# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UmpebcKbart, type: :model do
  subject(:umpebc_kbart) { create(:umpebc_kbart) }

  it do
    expect(umpebc_kbart).to be_valid
    expect(umpebc_kbart.update?).to be true
    expect(umpebc_kbart.destroy?).to be true
    expect(UmpebcKbart.count).to eq(1)

    umpebc_kbart.destroy
    expect(UmpebcKbart.count).to be_zero
  end
end
