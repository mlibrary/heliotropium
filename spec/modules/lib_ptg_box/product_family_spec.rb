# frozen_string_literal: true

require 'rails_helper'

RSpec.describe LibPtgBox::ProductFamily do
  subject { described_class.new(family_folder) }

  let(:family_folder) { object_double(LibPtgBox::Unmarshaller::FamilyFolder.new(box_folder), 'family_folder') }
  let(:box_folder) { instance_double(Box::Folder, 'box_folder', name: 'name') }

  before do
    allow(family_folder).to receive(:name).and_return(box_folder.name)
  end

  it { is_expected.not_to be_nil }
end
