# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Uuid, type: :model do
  describe '#facotry' do
    subject(:resource) { described_class.factory(uuid) }

    # rubocop:disable RSpec/NestedGroups

    context 'when NullResource' do
      context 'when nil' do
        let(:uuid) { nil }

        it { expect(resource).to be_an_instance_of(NullResource) }
        it { expect(resource.uuid).to be uuid }
      end

      context 'when null' do
        let(:uuid) { '00000000-0000-0000-0000-000000000000' }

        it { expect(resource).to be_an_instance_of(NullResource) }
        it { expect(resource.uuid).to be uuid }
      end

      context 'when invalid uuid' do
        let(:uuid) { '00000000-0000-0000-0000-00000000000X' }

        it { expect(resource).to be_an_instance_of(NullResource) }
        it { expect(resource.uuid).to be uuid }
      end
    end

    # rubocop:enable RSpec/NestedGroups

    context 'when Resource' do
      let(:uuid) { '00000000-0000-0000-0000-00000000000f' }

      it { expect(resource).to be_an_instance_of(Resource) }
      it { expect(resource.uuid).to be uuid }
    end
  end

  describe '#uuid_valid?' do
    let(:uuid) { '00000000-0000-0000-0000-00000000000g' }

    it { expect(described_class.uuid_valid?(uuid)).to be false }

    context 'when valid' do
      let(:uuid) { '00000000-0000-0000-0000-00000000000f' }

      it { expect(described_class.uuid_valid?(uuid)).to be true }
    end
  end

  describe '#uuid_null_packed' do
    subject { described_class.uuid_null_packed }

    it { is_expected.to eq(Array.new(16, 0).pack('C*').force_encoding('ascii-8bit')) }
  end

  describe '#uuid_null_unpacked' do
    subject { described_class.uuid_null_unpacked }

    it { is_expected.to eq('00000000-0000-0000-0000-000000000000') }
  end

  describe '#uuid_pack' do
    subject { described_class.uuid_pack(unpacked) }

    let(:unpacked) { described_class.uuid_null_unpacked }

    it { is_expected.to eq(described_class.uuid_null_packed) }

    context 'when 0x0F' do
      let(:unpacked) { '0f0f0f0f-0f0f-0f0f-0f0f-0f0f0f0f0f0f' }

      it { is_expected.to eq(Array.new(16, 15).pack('C*').force_encoding('ascii-8bit')) }
    end

    context 'when 0xFF' do
      let(:unpacked) { 'ffffffff-ffff-ffff-ffff-ffffffffffff' }

      it { is_expected.to eq(Array.new(16, 255).pack('C*').force_encoding('ascii-8bit')) }
    end
  end

  describe '#uuid_unpack' do
    subject { described_class.uuid_unpack(packed) }

    let(:packed) { described_class.uuid_null_packed }

    it { is_expected.to eq(described_class.uuid_null_unpacked) }

    context 'when \x0F' do
      let(:packed) { Array.new(16, 15).pack('C*').force_encoding('ascii-8bit') }

      it { is_expected.to eq('0f0f0f0f-0f0f-0f0f-0f0f-0f0f0f0f0f0f') }
    end

    context 'when \xFF' do
      let(:packed) { Array.new(16, 255).pack('C*').force_encoding('ascii-8bit') }

      it { is_expected.to eq('ffffffff-ffff-ffff-ffff-ffffffffffff') }
    end
  end

  describe '#null' do
    subject(:null) { described_class.null }

    it 'is null' do
      expect(null).to be_an_instance_of(described_class)
      expect(null.packed).to eq(described_class.uuid_null_packed)
      expect(null.unpacked).to eq(described_class.uuid_null_unpacked)
    end
  end

  describe '#generator' do
    subject(:uuid) { described_class.generator }

    before { allow(described_class).to receive(:uuid_generator_packed).and_return(Support.random_uuid_packed) }

    it 'is non null' do
      expect(uuid).to be_an_instance_of(described_class)
      expect(uuid.packed).not_to eq(described_class.uuid_null_packed)
      expect(uuid.unpacked).not_to eq(described_class.uuid_null_unpacked)
    end
  end

  describe 'checkpoint resource' do
    subject(:uuid) { create(:uuid) }

    it 'is a checkpoint resource' do
      expect(uuid.resource_type).to eq(:Uuid)
      expect(uuid.resource_id).to eq(uuid.id)
      expect(uuid.resource_token).to eq(uuid.resource_type.to_s + ':' + uuid.resource_id.to_s)
    end
  end

  context 'when exercised' do
    subject(:uuid) { create(:uuid) }

    it 'is expected' do # rubocop:disable RSpec/ExampleLength
      expect(uuid).to be_valid
      expect(uuid.resource_type).to eq :Uuid
      expect(uuid.resource_id).to eq uuid.id
      expect(uuid.identifiers).to be_empty
      expect(uuid.update?).to be false
      expect(uuid.destroy?).to be true
      expect(Identifier.count).to be_zero
      expect(UuidIdentifier.count).to be_zero
      expect(Uuid.count).to eq(1)

      n = 3
      identifiers = []
      n.times { identifiers << create(:identifier) }
      expect(Identifier.count).to eq(n)

      identifiers.each_with_index do |identifier, index|
        expect(uuid.identifiers.count).to eq(index)
        uuid.identifiers << identifier
        uuid.save!
        expect(uuid.update?).to be false
        expect(uuid.destroy?).to be false
        expect(UuidIdentifier.count).to eq(index + 1)
      end

      identifiers.each_with_index do |identifier, index|
        expect(uuid.update?).to be false
        expect(uuid.destroy?).to be false
        expect(uuid.identifiers.count).to eq(n - index)
        uuid.identifiers.delete(identifier)
        uuid.save!
        expect(UuidIdentifier.count).to eq(n - (index + 1))
      end

      expect(uuid.update?).to be false
      expect(uuid.destroy?).to be true
      expect(Identifier.count).to eq(n)
      expect(UuidIdentifier.count).to be_zero
      expect(Uuid.count).to eq(1)

      identifiers.each(&:destroy)
      uuid.destroy
      expect(Identifier.count).to be_zero
      expect(Uuid.count).to be_zero
    end
  end
end
