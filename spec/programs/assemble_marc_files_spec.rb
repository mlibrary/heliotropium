# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AssembleMarcFiles do
  describe '#run' do
    let(:assemble_marc_files) { instance_double(AssembleMarcFiles::AssembleMarcFiles, "AssembleMarcFiles") }
    let(:mailer) { double("NotifierMailer") } # rubocop:disable RSpec/VerifiedDoubles

    before do
      allow(AssembleMarcFiles::AssembleMarcFiles).to receive(:new).and_return(assemble_marc_files)
      allow(mailer).to receive(:deliver_now)
    end

    context 'when log empty' do
      before do
        allow(assemble_marc_files).to receive(:execute).and_return("")
        allow(NotifierMailer).to receive(:administrators).with(anything).and_return(mailer)
      end

      it 'does not notifies administrators' do
        described_class.run
        expect(assemble_marc_files).to have_received(:execute)
        expect(mailer).not_to have_received(:deliver_now)
      end
    end

    context 'when log non-empty' do
      before do
        allow(assemble_marc_files).to receive(:execute).and_return("log\n")
        allow(NotifierMailer).to receive(:administrators).with("log\n").and_return(mailer)
      end

      it 'notifies administrators' do
        described_class.run
        expect(assemble_marc_files).to have_received(:execute)
        expect(mailer).to have_received(:deliver_now)
      end
    end

    context 'when standard error' do
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
