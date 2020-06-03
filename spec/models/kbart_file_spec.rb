# frozen_string_literal: true

require 'rails_helper'

RSpec.describe KbartFile, type: :model do
  subject(:kbart_file) { create(:kbart_file) }

  it do
    expect(kbart_file).to be_valid
    expect(kbart_file.update?).to be true
    expect(kbart_file.destroy?).to be true
    expect(described_class.count).to eq(1)

    kbart_file.destroy
    expect(described_class.count).to be_zero
  end
end
