# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Identifier, type: :model do
  subject(:identifier) { create(:identifier) }

  it 'is a checkpoint resource' do
    expect(identifier.resource_type).to eq(:Identifier)
    expect(identifier.resource_id).to eq(identifier.id)
    expect(identifier.resource_token).to eq(identifier.resource_type.to_s + ':' + identifier.resource_id.to_s)
  end

  it do
    expect(identifier).to be_valid
    expect(identifier.resource_type).to eq :Identifier
    expect(identifier.resource_id).to eq identifier.id
    expect(identifier.uuid).to be nil
    expect(identifier.update?).to be true
    expect(identifier.destroy?).to be true
    expect(Identifier.count).to eq(1)
    expect(UuidIdentifier.count).to be_zero
    expect(Uuid.count).to be_zero

    uuid = create(:uuid)
    expect(Uuid.count).to eq(1)

    identifier.uuid = uuid
    identifier.save!
    identifier.reload
    expect(identifier.uuid).to eq(uuid)
    expect(identifier.update?).to be true
    expect(identifier.destroy?).to be false
    expect { identifier.destroy }.to raise_exception(ActiveRecord::StatementInvalid)
    expect(Identifier.count).to eq(1)
    expect(UuidIdentifier.count).to eq(1)
    expect(Uuid.count).to eq(1)

    uuid2 = create(:uuid)
    expect(Uuid.count).to eq(2)

    # expect { identifier.uuid = uuid2 }.to raise_exception(NoMethodError)

    uuid.identifiers.destroy(identifier)
    identifier.reload
    expect(identifier.uuid).to be nil
    expect(identifier.update?).to be true
    expect(identifier.destroy?).to be true
    expect(Identifier.count).to eq(1)
    expect(UuidIdentifier.count).to be_zero
    expect(Uuid.count).to eq(2)

    identifier.uuid = uuid2
    identifier.save!
    identifier.reload
    expect(identifier.uuid).to eq(uuid2)
    expect(identifier.update?).to be true
    expect(identifier.destroy?).to be false
    expect { identifier.destroy }.to raise_exception(ActiveRecord::StatementInvalid)
    expect(Identifier.count).to eq(1)
    expect(UuidIdentifier.count).to eq(1)
    expect(Uuid.count).to eq(2)

    uuid.destroy
    expect(Identifier.count).to eq(1)
    expect(UuidIdentifier.count).to eq(1)
    expect(Uuid.count).to eq(1)

    uuid2.identifiers.destroy(identifier)
    identifier.reload
    expect(identifier.uuid).to be nil
    expect(identifier.update?).to be true
    expect(identifier.destroy?).to be true
    expect(Identifier.count).to eq(1)
    expect(UuidIdentifier.count).to be_zero
    expect(Uuid.count).to eq(1)

    identifier.destroy
    expect(Identifier.count).to be_zero
    expect(UuidIdentifier.count).to be_zero
    expect(Uuid.count).to eq(1)

    uuid2.destroy
    expect(Identifier.count).to be_zero
    expect(UuidIdentifier.count).to be_zero
    expect(Uuid.count).to be_zero
  end
end
