# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AssembleMarcFiles do
  describe '#run' do
    let(:lib_ptg_box) { instance_double(LibPtgBox::LibPtgBox, 'lib_ptg_box') }
    let(:assemble_marc_files) { instance_double(AssembleMarcFiles::AssembleMarcFiles, "AssembleMarcFiles") }
    let(:mailer) { double("NotifierMailer") } # rubocop:disable RSpec/VerifiedDoubles

    before do
      allow(LibPtgBox::LibPtgBox).to receive(:new).and_return(lib_ptg_box)
      allow(lib_ptg_box).to receive(:synchronize_catalog_marcs).and_return([])
      allow(lib_ptg_box).to receive(:synchronize_umpbec_kbarts).and_return([])
      allow(AssembleMarcFiles::AssembleMarcFiles).to receive(:new).with(lib_ptg_box).and_return(assemble_marc_files)
      allow(assemble_marc_files).to receive(:execute).and_return(nil)
      allow(assemble_marc_files).to receive(:errors).and_return([])
      allow(NotifierMailer).to receive(:administrators).with(anything).and_return(mailer)
      allow(mailer).to receive(:deliver_now)
      allow(CatalogMarc).to receive(:destroy_all)
      allow(UmpebcKbart).to receive(:destroy_all)
    end

    context 'when options' do
      it 'default' do
        described_class.run
        expect(CatalogMarc).not_to have_received(:destroy_all)
        expect(lib_ptg_box).to have_received(:synchronize_catalog_marcs)
        expect(UmpebcKbart).not_to have_received(:destroy_all)
        expect(lib_ptg_box).to have_received(:synchronize_umpbec_kbarts)
        expect(assemble_marc_files).to have_received(:execute)
      end

      it 'skip_catalog_sync' do
        described_class.run(skip_catalog_sync: true)
        expect(CatalogMarc).not_to have_received(:destroy_all)
        expect(lib_ptg_box).not_to have_received(:synchronize_catalog_marcs)
        expect(UmpebcKbart).not_to have_received(:destroy_all)
        expect(lib_ptg_box).to have_received(:synchronize_umpbec_kbarts)
        expect(assemble_marc_files).to have_received(:execute)
      end

      it 'reset_catalog_marcs' do
        described_class.run(reset_catalog_marcs: true)
        expect(CatalogMarc).to have_received(:destroy_all)
        expect(lib_ptg_box).to have_received(:synchronize_catalog_marcs)
        expect(UmpebcKbart).not_to have_received(:destroy_all)
        expect(lib_ptg_box).to have_received(:synchronize_umpbec_kbarts)
        expect(assemble_marc_files).to have_received(:execute)
      end

      it 'reset_umpebc_kbarts' do
        described_class.run(reset_umpebc_kbarts: true)
        expect(CatalogMarc).not_to have_received(:destroy_all)
        expect(lib_ptg_box).to have_received(:synchronize_catalog_marcs)
        expect(UmpebcKbart).to have_received(:destroy_all)
        expect(lib_ptg_box).to have_received(:synchronize_umpbec_kbarts)
        expect(assemble_marc_files).to have_received(:execute)
      end
    end

    context 'when notifier mailer' do
      it 'default' do
        described_class.run
        expect(NotifierMailer).not_to have_received(:administrators).with(anything)
        expect(mailer).not_to have_received(:deliver_now)
      end

      context 'when catalog error' do
        before { allow(lib_ptg_box).to receive(:synchronize_catalog_marcs).and_return(['log']) }

        it do
          described_class.run
          expect(NotifierMailer).to have_received(:administrators).with('log')
          expect(mailer).to have_received(:deliver_now)
        end
      end

      context 'when umpbec error' do
        before { allow(lib_ptg_box).to receive(:synchronize_umpbec_kbarts).and_return(['log']) }

        it do
          described_class.run
          expect(NotifierMailer).to have_received(:administrators).with('log')
          expect(mailer).to have_received(:deliver_now)
        end
      end

      context 'when execute error' do
        before { allow(assemble_marc_files).to receive(:errors).and_return(['errors']) }

        it do
          described_class.run
          expect(NotifierMailer).to have_received(:administrators).with('errors')
          expect(mailer).to have_received(:deliver_now)
        end
      end

      context 'when standard error' do
        before { allow(assemble_marc_files).to receive(:execute).and_raise(StandardError) }

        it do
          described_class.run
          expect(NotifierMailer).to have_received(:administrators).with("AssembleMarcFiles run error (StandardError)\n")
          expect(mailer).to have_received(:deliver_now)
        end
      end
    end
  end
end
