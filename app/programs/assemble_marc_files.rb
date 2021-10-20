# frozen_string_literal: true

require_relative 'assemble_marc_files/assemble_marc_files'

module AssembleMarcFiles
  class << self
    def run(options = {}) # rubocop:disable Metrics/MethodLength, Metrics/AbcSize, Metrics/PerceivedComplexity, Metrics/CyclomaticComplexity
      # NotifierMailer.administrators("AssembleMarcFiles.run", "AssembleMarcFiles.run").deliver_now

      Net::SFTP.start(Settings.ftp_fulcrum_org.host, Settings.ftp_fulcrum_org.user, password: Settings.ftp_fulcrum_org.password) do |sftp| # rubocop:disable Metrics/BlockLength
        # Object wrapper for ftp.fulcrum.org
        ftp_fulcrum_org = FtpFulcrumOrg::FtpFulcrumOrg.new(sftp)

        # Destroying all MarcRecord records will force downloading of all MARC from Cataloging files
        MarcRecord.destroy_all if options[:reset_marc_records]

        # Clear selected flag on all MarcRecord records
        MarcRecord.update_all(selected: false)

        # Destroying all KbartMarc records will force recreation of all KbartMarc records
        KbartMarc.destroy_all if options[:reset_kbart_marcs]

        # Destroying all MarcFile records will force uploading of all MARC files
        MarcFile.destroy_all if options[:reset_upload_checksums]

        # Destroying all KbartFile records will force reassembly of all MARC files
        KbartFile.destroy_all if options[:reset_kbart_files] || options[:reset_kbart_marcs] || options[:reset_upload_checksums]

        delta = !!(Date.today.day == 15 || options[:create_marc_deltas]) # rubocop:disable Style/DoubleNegation

        program = AssembleMarcFiles.new(ftp_fulcrum_org)
        ftp_fulcrum_org.publishers.each do |publisher|
          unless options[:skip_catalog_sync] && !options[:reset_marc_records]
            log = ftp_fulcrum_org.synchronize_marc_records(publisher)
            if log.present? # rubocop:disable Style/IfUnlessModifier
              NotifierMailer.administrators("synchronize_marc_records(#{publisher.key})", log.map(&:to_s).join("\n")).deliver_now
            end
          end

          log = ftp_fulcrum_org.synchronize_kbart_files(publisher)
          if log.present? # rubocop:disable Style/IfUnlessModifier
            NotifierMailer.administrators("synchronize_kbart_files(#{publisher.key})", log.map(&:to_s).join("\n")).deliver_now
          end

          log = program.assemble_marc_files(publisher, delta)
          if log.present?
            NotifierMailer.administrators("marc_file_updates(#{publisher.key})", log.map(&:to_s).join("\n")).deliver_now
            NotifierMailer.marc_file_updates(publisher, log.map(&:to_s).join("\n")).deliver_now
          end
          if program.errors.present?
            NotifierMailer.administrators("missing_record(#{publisher.key})", program.errors.map(&:to_s).join("\n")).deliver_now
            NotifierMailer.missing_record(publisher, program.errors.map(&:to_s).join("\n")).deliver_now
          end
        end
      rescue StandardError => e
        msg = <<~MSG
          AssembleMarcFiles run error #{e.message} (#{e.backtrace})
        MSG
        NotifierMailer.administrators("StandardError", msg).deliver_now
      end
    end
  end
end
