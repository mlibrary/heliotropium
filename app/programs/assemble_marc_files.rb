# frozen_string_literal: true

require_relative 'assemble_marc_files/assemble_marc_files'

module AssembleMarcFiles
  class << self
    def run(options = {}) # rubocop:disable Metrics/MethodLength, Metrics/AbcSize, Metrics/PerceivedComplexity, Metrics/CyclomaticComplexity
      # Object wrapper for M | box - All Files > Library PTG Box
      lib_ptg_box = LibPtgBox::LibPtgBox.new

      unless options[:skip_catalog_sync]
        # Synchronize CatalogMarcs table with M | box - All Files > Library PTG Box > UMPEBC Metadata > MARC from Cataloging folder
        # Destroying all the CatalogMarc records will force downloading of all MARC from Cataloging files
        CatalogMarc.destroy_all if options[:reset_catalog_marcs]
        log = lib_ptg_box.synchronize_catalog_marcs
        if log.present? # rubocop:disable Style/IfUnlessModifier
          NotifierMailer.administrators(log.map(&:to_s).join("\n")).deliver_now
        end
      end

      # MARC from Cataloging invalid UTF-8 encoding
      log = lib_ptg_box.invalid_utf_8_encoding
      if log.present?
        NotifierMailer.administrators(log.map(&:to_s).join("\n")).deliver_now
        NotifierMailer.mpub_cataloging_encoding_error(log.map(&:to_s).join("\n")).deliver_now
      end

      # Synchronize UmpebcKbart table with M | box - All Files > Library PTG Box > UMPEBC Metadata > UMPEBC KBART folder
      # Destroying all the UmpebcKbart records will force reassembly of all UMPEBC MARC files
      UmpebcKbart.destroy_all if options[:reset_umpebc_kbarts]
      log = lib_ptg_box.synchronize_umpbec_kbarts
      if log.present? # rubocop:disable Style/IfUnlessModifier
        NotifierMailer.administrators(log.map(&:to_s).join("\n")).deliver_now
      end

      # Assemble MARC files and upload changes to M | box - All Files > Library PTG Box > UMPEBC Metadata > UMPEBC MARC folder
      program = AssembleMarcFiles.new(lib_ptg_box)
      log = program.execute
      if log.present?
        NotifierMailer.administrators(log.map(&:to_s).join("\n")).deliver_now
        NotifierMailer.fulcrum_info_umpebc_marc_updates(log.map(&:to_s).join("\n")).deliver_now
      end
      if program.errors.present?
        NotifierMailer.administrators(program.errors.map(&:to_s).join("\n")).deliver_now
        NotifierMailer.mpub_cataloging_missing_record(program.errors.map(&:to_s).join("\n")).deliver_now
      end
    rescue StandardError => e
      msg = <<~MSG
        AssembleMarcFiles run error (#{e.backtrace})
      MSG
      NotifierMailer.administrators(msg).deliver_now
    end
  end
end
