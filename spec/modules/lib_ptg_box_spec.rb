# frozen_string_literal: true

require 'rails_helper'

RSpec.describe LibPtgBox do
  it '#chdir_lib_ptg_box_dir' do
    described_class.chdir_lib_ptg_box_dir
    expect(Dir.pwd).to eq(Rails.root.join('tmp', 'lib_ptg_box').to_s)
  end
end
