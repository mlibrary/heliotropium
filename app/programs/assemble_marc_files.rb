# frozen_string_literal: true

require_relative 'assemble_marc_files/assemble_marc_files'

module AssembleMarcFiles
  class << self
    def run(options = {}) # rubocop:disable Metrics/MethodLength, Metrics/AbcSize, Metrics/PerceivedComplexity, Metrics/CyclomaticComplexity
      # NotifierMailer.administrators("AssembleMarcFiles.run", "AssembleMarcFiles.run").deliver_now

      # Object wrapper for M | box - All Files > Library PTG Box
      lib_ptg_box = LibPtgBox::LibPtgBox.new

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

      program = AssembleMarcFiles.new(lib_ptg_box)
      lib_ptg_box.collections.each do |collection|
        unless options[:skip_catalog_sync] && !options[:reset_marc_records]
          log = lib_ptg_box.synchronize_marc_records(collection)
          if log.present? # rubocop:disable Style/IfUnlessModifier
            NotifierMailer.administrators("synchronize_marc_records(#{collection.key})", log.map(&:to_s).join("\n")).deliver_now
          end
        end

        log = lib_ptg_box.synchronize_kbart_files(collection)
        if log.present? # rubocop:disable Style/IfUnlessModifier
          NotifierMailer.administrators("synchronize_kbart_files(#{collection.key})", log.map(&:to_s).join("\n")).deliver_now
        end

        log = program.assemble_marc_files(collection)
        if log.present?
          NotifierMailer.administrators("marc_file_updates(#{collection.key})", log.map(&:to_s).join("\n")).deliver_now
          NotifierMailer.marc_file_updates(collection, log.map(&:to_s).join("\n")).deliver_now
        end
        if program.errors.present?
          NotifierMailer.administrators("missing_record(#{collection.key})", program.errors.map(&:to_s).join("\n")).deliver_now
          NotifierMailer.missing_record(collection, program.errors.map(&:to_s).join("\n")).deliver_now
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
