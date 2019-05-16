# frozen_string_literal: true

require 'rails_helper'

RSpec.describe LibPtgBox::Unmarshaller::KbartFile do
  subject { described_class.new(box_file) }

  let(:box_file) { instance_double(Box::File, 'box_file') }

  it { is_expected.not_to be_nil }
end
