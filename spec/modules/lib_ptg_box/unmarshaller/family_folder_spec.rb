# frozen_string_literal: true

require 'rails_helper'

RSpec.describe LibPtgBox::Unmarshaller::FamilyFolder do
  subject { described_class.new(box_folder) }

  let(:box_folder) { instance_double(Box::Folder, 'box_folder') }

  it { is_expected.not_to be_nil }
end
