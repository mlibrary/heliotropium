# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Box::Folder do
  subject { described_class.new(folder) }

  let(:folder) { instance_double(BoxrMash, 'folder') }

  before do
    allow(folder).to receive(:[]).with(:etag).and_return('etag')
    allow(folder).to receive(:[]).with(:id).and_return('id')
    allow(folder).to receive(:[]).with(:name).and_return('name')
    allow(folder).to receive(:[]).with(:type).and_return('folder')
  end

  it { is_expected.not_to be_nil }
end
