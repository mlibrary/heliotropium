# frozen_string_literal: true

require 'rails_helper'

RSpec.describe LibPtgBox::Unmarshaller::FamilyFolder do
  subject(:family_folder) { described_class.new(family_box_folder) }

  let(:family_box_folder) { instance_double(Box::Folder, 'family_box_folder') }
  let(:box_folders) { [] }

  before do
    allow(family_box_folder).to receive(:folders).and_return(box_folders)
  end

  describe '#kbart_folder' do
    subject(:kbart_folder) { family_folder.kbart_folder }

    it { expect(kbart_folder.name).to eq('NullFolder') }

    context 'with kbart folder' do
      let(:box_folders) { [kbart_box_folder] }
      let(:kbart_box_folder) { instance_double(Box::Folder, 'kbart_box_folder', name: 'kbart') }

      it { expect(kbart_folder.name).to eq('kbart') }
    end
  end

  describe '#marc_folder' do
    subject(:marc_folder) { family_folder.marc_folder }

    it { expect(marc_folder.name).to eq('NullFolder') }

    context 'with marc folder' do
      let(:box_folders) { [marc_box_folder] }
      let(:marc_box_folder) { instance_double(Box::Folder, 'marc_box_folder', name: 'name') }

      it { expect(marc_folder.name).to eq('name') }
    end
  end

  describe '#cataloging_marc_folder' do
    subject(:cataloging_marc_folder) { family_folder.cataloging_marc_folder }

    it { expect(cataloging_marc_folder.name).to eq('NullFolder') }

    context 'with cataloging marc folder' do
      let(:box_folders) { [cataloging_marc_box_folder] }
      let(:cataloging_marc_box_folder) { instance_double(Box::Folder, 'cataloging_marc_box_folder', name: 'cataloging') }

      it { expect(cataloging_marc_folder.name).to eq('cataloging') }
    end
  end
end
