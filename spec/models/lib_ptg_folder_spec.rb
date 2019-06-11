# frozen_string_literal: true

require 'rails_helper'

RSpec.describe LibPtgFolder, type: :model do
  subject(:lib_ptg_folder) { create(:lib_ptg_folder) }

  it 'creates and destroys' do # rubocop:disable RSpec/ExampleLength
    expect(lib_ptg_folder).to be_valid
    expect(lib_ptg_folder.update?).to be true
    expect(lib_ptg_folder.destroy?).to be true
    expect(LibPtgFolder.count).to eq(1)

    lib_ptg_folder.destroy
    expect(LibPtgFolder.count).to be_zero
  end
end
