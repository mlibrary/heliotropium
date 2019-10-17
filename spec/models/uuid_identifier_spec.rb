# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UuidIdentifier, type: :model do
  subject(:uuid_identifier) { create(:uuid_identifier) }

  it do
    expect(uuid_identifier).to be_valid
    expect(Identifier.count).to eq(1)
    expect(Uuid.count).to eq(1)
    expect(UuidIdentifier.count).to eq(1)

    uuid_identifier.destroy
    expect(Identifier.count).to eq(1)
    expect(Uuid.count).to eq(1)
    expect(UuidIdentifier.count).to be_zero
  end
end
