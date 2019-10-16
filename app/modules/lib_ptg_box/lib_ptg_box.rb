# frozen_string_literal: true

module LibPtgBox
  class LibPtgBox # rubocop:disable Metrics/ClassLength
    def initialize
      # WARNING Instance sets pwd to ./tmp/lib_ptg_box and then assumes complete control of changing the pwd at will!!!
      chdir_lib_ptg_box_dir
    end

    def collections
      @collections ||= Unmarshaller::RootFolder.sub_folders.map { |sub_folder| Collection.new(sub_folder) }
    end

    # Synchronize CatalogMarcs table with M | box - All Files > Library PTG Box > UMPEBC Metadata > MARC from Cataloging folder
    def synchronize_catalog_marcs # rubocop:disable Metrics/MethodLength, Metrics/AbcSize, Metrics/PerceivedComplexity, Metrics/CyclomaticComplexity
      log = []

      # Previous MARC records list
      catalog_marcs = []
      CatalogMarc.all.each do |catalog_marc|
        catalog_marcs << catalog_marc
      end

      collections.each do |collection| # rubocop:disable Metrics/BlockLength
        # Only process UMPEBC Metadata folder.
        next unless /umpebc/i.match?(collection.name)

        # Find or create a record for each MARC mrc file (NOTE: Assumes 1:1 between record and file)
        collection.catalog.marc_folder.marc_files.each do |marc_file| # rubocop:disable Metrics/BlockLength
          next unless /.+\.mrc$/i.match?(marc_file.name)

          catalog_marc = CatalogMarc.find_or_create_by!(folder: collection.catalog.marc_folder.name, file: marc_file.name, isbn: /(^\d+)(.*$)/.match(marc_file.name)[1])

          if catalog_marc.selected
            catalog_marc.selected = false
            catalog_marc.save!
          end

          if catalog_marc.updated < marc_file.updated || catalog_marc.content.blank?
            catalog_marc.selected = true
            catalog_marc.updated = marc_file.updated
            catalog_marc.content = marc_file.content
            catalog_marc.save!
            log << "NEW FILE CONTENT in #{catalog_marc.folder} > #{catalog_marc.file}"
          end

          if catalog_marc.selected || catalog_marc.count != 1
            catalog_marc.selected = true
            catalog_marc.raw = nil
            catalog_marc.count = 0
            count = 0
            reader = MARC::Reader.new(StringIO.new(catalog_marc.content), external_encoding: "UTF-8", validate_encoding: true)
            reader.each_raw do |raw|
              catalog_marc.raw = raw unless count.positive?
              count += 1
            end
            catalog_marc.count = count
            catalog_marc.save!

            log << "NO MARC RECORD in #{catalog_marc.folder} > #{catalog_marc.file} record count = #{count}" if count < 1
            log << "MULTIPLE MARC RECORDS in #{catalog_marc.folder} > #{catalog_marc.file} record count = #{count}" if count > 1
          end

          if catalog_marc.selected || !catalog_marc.parsed || catalog_marc.replaced
            catalog_marc.selected = true
            catalog_marc.mrc = nil
            catalog_marc.doi = nil
            catalog_marc.parsed = false
            catalog_marc.replaced = false
            if count.positive?
              begin
                catalog_marc.mrc = MARC::Reader.decode(catalog_marc.raw, external_encoding: "UTF-8", validate_encoding: true)
                catalog_marc.parsed = true
                marc = Unmarshaller::Marc.new(catalog_marc.mrc)
                catalog_marc.doi = marc.doi
              rescue Encoding::InvalidByteSequenceError => e
                log << "ERROR #{e} reading #{catalog_marc.folder} > #{catalog_marc.file}"
                Rails.logger.error("LibPtgBox::LibPtgBox#synchronize_catalog_marcs(#{marc_file.name}) #{e}")
                begin
                  catalog_marc.mrc = MARC::Reader.decode(catalog_marc.raw, external_encoding: "UTF-8", invalid: :replace)
                  catalog_marc.parsed = true
                  catalog_marc.replaced = true
                  marc = Unmarshaller::Marc.new(catalog_marc.mrc)
                  catalog_marc.doi = marc.doi
                rescue StandardError => e # rubocop:disable Metrics/BlockNesting
                  log << "ERROR #{e} reading #{catalog_marc.folder} > #{catalog_marc.file}"
                  Rails.logger.error("LibPtgBox::LibPtgBox#synchronize_catalog_marcs(#{marc_file.name}) #{e}")
                end
              rescue StandardError => e
                log << "ERROR #{e} reading #{catalog_marc.folder} > #{catalog_marc.file}"
                Rails.logger.error("LibPtgBox::LibPtgBox#synchronize_catalog_marcs(#{marc_file.name}) #{e}")
              end
            end
            catalog_marc.save!
          end

          # Remove record from the previous records list
          catalog_marcs.delete(catalog_marc) if catalog_marcs.include?(catalog_marc)
        end
      end

      # Destroy orphan MARC records a.k.a. previous records that no longer have a matching MARC mrc file
      catalog_marcs.each do |catalog_marc|
        log << "FILE NOT FOUND  #{catalog_marc.folder} > #{catalog_marc.file} deleting orphan record"
        catalog_marc.destroy!
      end

      # Cataloging Errors
      CatalogMarc.where(replaced: true).each do |record|
        log << "INVALID UTF-8 encoding for #{record.folder} > #{record.file} https://doi.org/#{record.doi}"
        upper = MARC::Reader.decode(record.raw, external_encoding: "UTF-8", invalid: :replace, replace: 'Z')
        lower = MARC::Reader.decode(record.raw, external_encoding: "UTF-8", invalid: :replace, replace: 'z')
        upper.fields.each_with_index do |upper_field, index|
          lower_field = lower.fields[index]
          upper_set = upper_field.to_s.split(/\s/).to_set
          lower_set = lower_field.to_s.split(/\s/).to_set
          difference = upper_set ^ lower_set
          log << "field #{upper_field.tag} #{difference}" unless difference.empty?
        end
      end

      log
    end

    # Synchronize UmpebcKbart table with M | box - All Files > Library PTG Box > UMPEBC Metadata > UMPEBC KBART folder
    def synchronize_umpbec_kbarts # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
      log = []

      # Previous KBART records list
      umpebc_kbarts = []
      UmpebcKbart.all.each do |umpebc_kbart|
        umpebc_kbarts << umpebc_kbart
      end

      collections.each do |collection|
        # Only process UMPEBC Metadata folder.
        next unless /umpebc/i.match?(collection.name)

        # Find or create a record for each KBART csv file
        collection.selections.each do |selection|
          umpebc_kbart = UmpebcKbart.find_or_create_by!(name: selection.name, year: selection.year)
          # Remove record from the previous records list
          umpebc_kbarts.delete(umpebc_kbart) if umpebc_kbarts.include?(umpebc_kbart)
        end
      end

      # Destroy orphan KBART records a.k.a. previous records that no longer have a matching KBART csv file
      umpebc_kbarts.each do |umpebc_kbart|
        log << "FILE NOT FOUND for #{umpebc_kbart.name} #{umpebc_kbart.year} deleting orphan record"
        umpebc_kbart.destroy!
      end

      log
    end

    private

      def chdir_lib_ptg_box_dir
        tmp_dir = Rails.root.join('tmp')
        Dir.mkdir(tmp_dir) unless Dir.exist?(tmp_dir)
        Dir.chdir(tmp_dir)
        Dir.mkdir('lib_ptg_box') unless Dir.exist?('lib_ptg_box')
        Dir.chdir('lib_ptg_box')
      end
  end
end
