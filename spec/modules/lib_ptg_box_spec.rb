# frozen_string_literal: true

require 'rails_helper'

RSpec.describe LibPtgBox do
  it { is_expected.not_to be_nil }

  it { expect(LibPtgBox::BOX_LIB_PTG_BOX_PATH).to eq('/Library PTG Box') }

  # describe "#test" do
  #   subject { described_class.test }
  #
  #   xit { is_expected.not_to be_nil }
  # end
end
