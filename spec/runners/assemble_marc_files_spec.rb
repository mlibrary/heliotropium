# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AssembleMarcFiles do
  subject(:assemble_marc_files) { described_class.new }

  let(:client) { instance_double(Boxr::Client, 'client') }
  let(:boxr_mash) { instance_double(BoxrMash, 'boxr_mash') }
  let(:items) { [] }

  before do
    allow(Boxr::Client).to receive(:new).and_return(client)
    allow(client).to receive(:folder_from_path).with("/My Box Notes/cronuts/download/kbart").and_return(boxr_mash)
    allow(client).to receive(:folder_from_path).with("/My Box Notes/cronuts/download/marc").and_return(boxr_mash)
    allow(client).to receive(:folder_from_path).with("/My Box Notes/cronuts/download/catalog").and_return(boxr_mash)
    allow(client).to receive(:folder_from_path).with("/My Box Notes/cronuts/upload/marc").and_return(boxr_mash)
    allow(client).to receive(:folder_items).with(boxr_mash, fields: %i[id name]).and_return(items)
    allow(boxr_mash).to receive(:[]).with(:etag).and_return('etag')
    allow(boxr_mash).to receive(:[]).with(:id).and_return('id')
    allow(boxr_mash).to receive(:[]).with(:name).and_return('name')
    allow(boxr_mash).to receive(:[]).with(:type).and_return('file')
  end

  describe '#run' do
    subject { assemble_marc_files.run }

    it { is_expected.to be_nil }
  end
end
