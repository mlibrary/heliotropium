# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Box::Folder do
  subject { described_class.new(folder) }

  let(:folder) { instance_double(BoxrMash) }

  it { is_expected.not_to be_nil }
end
