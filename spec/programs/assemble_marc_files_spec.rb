# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AssembleMarcFiles do
  describe '#run' do
    let(:sftp) { instance_double(Net::SFTP::Session, 'sftp') }
    let(:ftp_fulcrum_org) { instance_double(FtpFulcrumOrg::FtpFulcrumOrg, 'ftp_fulcrum_org') }
    let(:publisher) { instance_double(FtpFulcrumOrg::Publisher, 'publisher', key: 'umpebc', name: 'UMPEBC') }
    let(:delta) { false }
    let(:assemble_marc_files) { instance_double(AssembleMarcFiles::AssembleMarcFiles, "AssembleMarcFiles") }
    let(:admin_mailer) { double('admin_mailer') } # rubocop:disable RSpec/VerifiedDoubles
    let(:fulcrum_info_mailer) { double('fulcrum_info_mailer') } # rubocop:disable RSpec/VerifiedDoubles
    let(:mpub_encoding_mailer) { double('mpub_encoding_mailer') } # rubocop:disable RSpec/VerifiedDoubles
    let(:mpub_missing_mailer) { double('mpub_missing_mailer') } # rubocop:disable RSpec/VerifiedDoubles

    before do
      allow(Net::SFTP).to receive(:start).with(Settings.ftp_fulcrum_org.host, Settings.ftp_fulcrum_org.user, password: Settings.ftp_fulcrum_org.password).and_yield(sftp)
      allow(FtpFulcrumOrg::FtpFulcrumOrg).to receive(:new).with(sftp).and_return(ftp_fulcrum_org)
      allow(ftp_fulcrum_org).to receive(:publishers).and_return([publisher])
      allow(ftp_fulcrum_org).to receive(:synchronize_marc_records).with(publisher).and_return([])
      allow(ftp_fulcrum_org).to receive(:synchronize_kbart_files).with(publisher).and_return([])
      allow(AssembleMarcFiles::AssembleMarcFiles).to receive(:new).with(ftp_fulcrum_org).and_return(assemble_marc_files)
      allow(assemble_marc_files).to receive(:assemble_marc_files).with(publisher, delta).and_return([])
      allow(assemble_marc_files).to receive(:errors).and_return([])
      allow(NotifierMailer).to receive(:administrators).with(anything, anything).and_return(admin_mailer)
      allow(NotifierMailer).to receive(:marc_file_updates).with(anything, anything).and_return(fulcrum_info_mailer)
      allow(NotifierMailer).to receive(:encoding_error).with(anything, anything).and_return(mpub_encoding_mailer)
      allow(NotifierMailer).to receive(:missing_record).with(anything, anything).and_return(mpub_missing_mailer)
      allow(admin_mailer).to receive(:deliver_now)
      allow(fulcrum_info_mailer).to receive(:deliver_now)
      allow(mpub_encoding_mailer).to receive(:deliver_now)
      allow(mpub_missing_mailer).to receive(:deliver_now)
      allow(MarcRecord).to receive(:destroy_all)
      allow(KbartFile).to receive(:destroy_all)
    end

    context 'when options' do
      it 'default' do
        described_class.run
        expect(MarcRecord).not_to have_received(:destroy_all)
        expect(ftp_fulcrum_org).to have_received(:synchronize_marc_records)
        expect(KbartFile).not_to have_received(:destroy_all)
        expect(ftp_fulcrum_org).to have_received(:synchronize_kbart_files)
        expect(assemble_marc_files).to have_received(:assemble_marc_files)
      end

      it 'skip_catalog_sync' do
        described_class.run(skip_catalog_sync: true)
        expect(MarcRecord).not_to have_received(:destroy_all)
        expect(ftp_fulcrum_org).not_to have_received(:synchronize_marc_records)
        expect(KbartFile).not_to have_received(:destroy_all)
        expect(ftp_fulcrum_org).to have_received(:synchronize_kbart_files)
        expect(assemble_marc_files).to have_received(:assemble_marc_files)
      end

      it 'reset_marc_records' do
        described_class.run(reset_marc_records: true)
        expect(MarcRecord).to have_received(:destroy_all)
        expect(ftp_fulcrum_org).to have_received(:synchronize_marc_records)
        expect(KbartFile).not_to have_received(:destroy_all)
        expect(ftp_fulcrum_org).to have_received(:synchronize_kbart_files)
        expect(assemble_marc_files).to have_received(:assemble_marc_files)
      end

      it 'reset_kbart_files' do
        described_class.run(reset_kbart_files: true)
        expect(MarcRecord).not_to have_received(:destroy_all)
        expect(ftp_fulcrum_org).to have_received(:synchronize_marc_records)
        expect(KbartFile).to have_received(:destroy_all)
        expect(ftp_fulcrum_org).to have_received(:synchronize_kbart_files)
        expect(assemble_marc_files).to have_received(:assemble_marc_files)
      end
    end

    context 'when notifier mailer' do
      it 'default' do
        described_class.run
        expect(NotifierMailer).not_to have_received(:administrators).with(anything, anything)
        expect(admin_mailer).not_to have_received(:deliver_now)
        expect(NotifierMailer).not_to have_received(:encoding_error).with(anything, anything)
        expect(mpub_encoding_mailer).not_to have_received(:deliver_now)
        expect(NotifierMailer).not_to have_received(:marc_file_updates).with(anything, anything)
        expect(fulcrum_info_mailer).not_to have_received(:deliver_now)
        expect(NotifierMailer).not_to have_received(:missing_record).with(anything, anything)
        expect(mpub_missing_mailer).not_to have_received(:deliver_now)
      end

      context 'when uploaded files' do
        before { allow(assemble_marc_files).to receive(:assemble_marc_files).with(publisher, delta).and_return(['filename']) }

        it do
          described_class.run
          expect(NotifierMailer).to have_received(:administrators).with('marc_file_updates(umpebc)', 'filename')
          expect(admin_mailer).to have_received(:deliver_now)
          expect(NotifierMailer).not_to have_received(:encoding_error).with(anything, anything)
          expect(mpub_encoding_mailer).not_to have_received(:deliver_now)
          expect(NotifierMailer).to have_received(:marc_file_updates).with(publisher, 'filename')
          expect(fulcrum_info_mailer).to have_received(:deliver_now)
          expect(NotifierMailer).not_to have_received(:missing_record).with(anything, anything)
          expect(mpub_missing_mailer).not_to have_received(:deliver_now)
        end
      end

      context 'when catalog error' do
        before { allow(ftp_fulcrum_org).to receive(:synchronize_marc_records).and_return(['log']) }

        it do
          described_class.run
          expect(NotifierMailer).to have_received(:administrators).with('synchronize_marc_records(umpebc)', 'log')
          expect(admin_mailer).to have_received(:deliver_now)
          expect(NotifierMailer).not_to have_received(:encoding_error).with(anything, anything)
          expect(mpub_encoding_mailer).not_to have_received(:deliver_now)
          expect(NotifierMailer).not_to have_received(:marc_file_updates).with(anything, anything)
          expect(fulcrum_info_mailer).not_to have_received(:deliver_now)
          expect(NotifierMailer).not_to have_received(:missing_record).with(anything, anything)
          expect(mpub_missing_mailer).not_to have_received(:deliver_now)
        end
      end

      context 'when umpbec error' do
        before { allow(ftp_fulcrum_org).to receive(:synchronize_kbart_files).and_return(['log']) }

        it do
          described_class.run
          expect(NotifierMailer).to have_received(:administrators).with('synchronize_kbart_files(umpebc)', 'log')
          expect(admin_mailer).to have_received(:deliver_now)
          expect(NotifierMailer).not_to have_received(:encoding_error).with(anything, anything)
          expect(mpub_encoding_mailer).not_to have_received(:deliver_now)
          expect(NotifierMailer).not_to have_received(:marc_file_updates).with(anything, anything)
          expect(fulcrum_info_mailer).not_to have_received(:deliver_now)
          expect(NotifierMailer).not_to have_received(:missing_record).with(anything, anything)
          expect(mpub_missing_mailer).not_to have_received(:deliver_now)
        end
      end

      context 'when execute error' do
        before { allow(assemble_marc_files).to receive(:errors).and_return(['errors']) }

        it do
          described_class.run
          expect(NotifierMailer).to have_received(:administrators).with('missing_record(umpebc)', 'errors')
          expect(admin_mailer).to have_received(:deliver_now)
          expect(NotifierMailer).not_to have_received(:encoding_error).with(anything, anything)
          expect(mpub_encoding_mailer).not_to have_received(:deliver_now)
          expect(NotifierMailer).not_to have_received(:marc_file_updates).with(anything, anything)
          expect(fulcrum_info_mailer).not_to have_received(:deliver_now)
          expect(NotifierMailer).to have_received(:missing_record).with(publisher, 'errors')
          expect(mpub_missing_mailer).to have_received(:deliver_now)
        end
      end

      context 'when standard error' do
        before { allow(assemble_marc_files).to receive(:assemble_marc_files).with(publisher, delta).and_raise(StandardError) }

        it do
          described_class.run
          expect(NotifierMailer).to have_received(:administrators).with('StandardError', /AssembleMarcFiles run error/)
          expect(admin_mailer).to have_received(:deliver_now)
          expect(NotifierMailer).not_to have_received(:encoding_error).with(anything, anything)
          expect(mpub_encoding_mailer).not_to have_received(:deliver_now)
          expect(NotifierMailer).not_to have_received(:marc_file_updates).with(anything, anything)
          expect(fulcrum_info_mailer).not_to have_received(:deliver_now)
          expect(NotifierMailer).not_to have_received(:missing_record).with(anything, anything)
          expect(mpub_missing_mailer).not_to have_received(:deliver_now)
        end
      end
    end
  end
end
