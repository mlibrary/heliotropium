# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Resource, type: :model do
  context 'when null resource' do
    subject(:null_resource) { described_class.null_resource }

    it { is_expected.to be_an_instance_of(NullResource) }
    it { expect(null_resource.uuid).to eq '00000000-0000-0000-0000-000000000000' }
    it { expect(null_resource.valid?).to be false }
    it { expect(null_resource.resource_type).to eq :Resource }
    it { expect(null_resource.resource_id).to eq '00000000-0000-0000-0000-000000000000' }
    it { expect(null_resource.resource_token).to eq "#{null_resource.resource_type}:#{null_resource.resource_id}" }
  end

  context 'when resource' do
    subject(:resource) { described_class.send(:new, uuid) }

    let(:uuid) { 'valid_uuid' }

    it { expect(resource).to be_an_instance_of(described_class) }
    it { expect(resource.uuid).to eq uuid }
    it { expect(resource.valid?).to be true }
    it { expect(resource.resource_type).to eq :Resource }
    it { expect(resource.resource_id).to eq uuid }
    it { expect(resource.resource_token).to eq "#{resource.resource_type}:#{resource.resource_id}" }
  end
end
