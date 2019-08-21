# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AssembleMarcFiles do
  describe '#run' do
    let(:assemble_marc_files) { instance_double(AssembleMarcFiles::AssembleMarcFiles, "AssembleMarcFiles") }
    let(:mailer) { double("NotifierMailer") } # rubocop:disable RSpec/VerifiedDoubles

    before do
      allow(AssembleMarcFiles::AssembleMarcFiles).to receive(:new).and_return(assemble_marc_files)
      allow(assemble_marc_files).to receive(:execute).and_return(nil)
      allow(assemble_marc_files).to receive(:errors).and_return(errors)
      allow(NotifierMailer).to receive(:administrators).with(anything).and_return(mailer)
      allow(mailer).to receive(:deliver_now)
    end

    context 'when no errors' do
      let(:errors) { [] }

      it 'does not notifies administrators' do
        described_class.run
        expect(assemble_marc_files).to have_received(:execute)
        expect(mailer).not_to have_received(:deliver_now)
      end
    end

    context 'when errors' do
      let(:errors) { ["error"] }

      it 'notifies administrators' do
        described_class.run
        expect(assemble_marc_files).to have_received(:execute)
        expect(mailer).to have_received(:deliver_now)
      end
    end

    context 'when standard error' do
      let(:errors) { [] }

      before do
        allow(assemble_marc_files).to receive(:execute).and_raise(StandardError)
        allow(NotifierMailer).to receive(:administrators).with("AssembleMarcFiles run error (StandardError)\n").and_return(mailer)
      end

      it 'notifies administrators' do
        described_class.run
        expect(mailer).to have_received(:deliver_now)
      end
    end
  end
end
