# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Box::File do
  subject { described_class.new(file) }

  let(:file) { instance_double(BoxrMash) }

  before do
    allow(file).to receive(:[]).with(:etag).and_return('etag')
    allow(file).to receive(:[]).with(:id).and_return('id')
    allow(file).to receive(:[]).with(:type).and_return('type')
    allow(file).to receive(:[]).with(:name).and_return('name')
  end

  it { is_expected.not_to be_nil }
end
