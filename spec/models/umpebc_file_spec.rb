# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UmpebcFile, type: :model do
  subject(:umpebc_file) { create(:umpebc_file) }

  it do
    expect(umpebc_file).to be_valid
    expect(umpebc_file.update?).to be true
    expect(umpebc_file.destroy?).to be true
    expect(UmpebcFile.count).to eq(1)

    umpebc_file.destroy
    expect(UmpebcFile.count).to be_zero
  end
end
