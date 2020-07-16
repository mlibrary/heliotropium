# frozen_string_literal: true

module LibPtgBox
  class LibPtgBox
    def initialize
      # WARNING Instance sets pwd to ./tmp/lib_ptg_box and then assumes complete control of changing the pwd at will!!!
      ::LibPtgBox.chdir_lib_ptg_box_dir
    end

    def collections
      return @collections if @collections.present?

      @collections = []
      Settings.lib_ptg_box.collections.each do |collection|
        Unmarshaller::RootFolder.sub_folders.each do |sub_folder|
          next unless collection.folder == sub_folder.name

          @collections << Collection.new(collection, sub_folder)
          break
        end
      end

      @collections
    end

    def synchronize_marc_records(collection) # rubocop:disable Metrics/MethodLength, Metrics/AbcSize, Metrics/PerceivedComplexity, Metrics/CyclomaticComplexity
      log = []

      # Previous MARC records list
      marc_records = []
      MarcRecord.where("folder = ?", collection.key).each do |marc_record|
        marc_records << marc_record
      end

      # Find or create a record for each MARC mrc/xml file (NOTE: Assumes 1:1 between record and file)
      collection.catalog.marc_folder.marc_files.each do |marc_file| # rubocop:disable Metrics/BlockLength
        next unless /.+\.(mrc|xml)$/i.match?(marc_file.name)

        marc_record = MarcRecord.find_or_create_by!(folder: collection.key, file: marc_file.name)

        # Clear selected flag. The selected flag will be set later if the record is updated.
        if marc_record.selected
          marc_record.selected = false
          marc_record.save!
        end

        if marc_record.updated < marc_file.updated || marc_record.content.blank? || marc_record.mrc.blank? || marc_record.count != 1 || !marc_record.parsed?
          begin
            marc_record.selected = true
            marc_record.updated = marc_file.updated
            marc_record.content = marc_file.content
            reader = if /.+\.mrc$/i.match?(marc_file.name)
                       MARC::Reader.new(StringIO.new(marc_record.content), external_encoding: "UTF-8", validate_encoding: true)
                     else
                       MARC::XMLReader.new(StringIO.new(marc_record.content))
                     end
            count = 0
            reader.each do |mrc|
              unless count.positive?
                marc_record.mrc = mrc.to_marc
                marc_record.doi = Unmarshaller::Marc.new(mrc).doi
              end
              count += 1
            end
            marc_record.count = count
            marc_record.parsed = count.positive?
            marc_record.save!
            log << "INFO: MARC Record updated in #{marc_record.folder} > #{marc_record.file}"
            log << "ERROR: NO MARC Record in #{marc_record.folder} > #{marc_record.file} record count = #{count}" if count < 1
            log << "WARNING: MULTIPLE MARC Records in #{marc_record.folder} > #{marc_record.file} record count = #{count}" if count > 1
          rescue StandardError => e
            log << "ERROR: #{e} reading MARC Record in #{marc_record.folder} > #{marc_record.file}"
            marc_record.selected = false
            marc_record.updated = Time.new(1970, 1, 1, 0, 0, 0, 0)
            marc_record.content = nil
            marc_record.mrc = nil
            marc_record.doi = nil
            marc_record.count = 0
            marc_record.parsed = false
            marc_record.save!
          end
        end

        # Remove record from the previous records list
        marc_records.delete(marc_record) if marc_records.include?(marc_record)
      end

      # Log orphan MARC records a.k.a. previous records that no longer have a matching MARC file
      marc_records.each do |marc_record|
        log << "WARNING: MARC FILE NOT FOUND #{marc_record.folder} > #{marc_record.file}"
      end

      log
    end

    def synchronize_kbart_files(collection) # rubocop:disable Metrics/MethodLength, Metrics/AbcSize, Metrics/CyclomaticComplexity
      log = []

      # Previous KBART records list
      kbart_files = []
      KbartFile.where("folder = ?", collection.key).each do |kbart_file|
        kbart_files << kbart_file
      end

      # Find or create a record for each KBART csv file
      collection.selections.each do |selection|
        kbart_file = KbartFile.find_or_create_by!(folder: collection.key, name: selection.name)
        # Remove record from the previous records list
        kbart_files.delete(kbart_file) if kbart_files.include?(kbart_file)
        next unless kbart_file.verified

        # Falsify verified KBART records that are dependent upon any updated (a.k.a. selected) MARC records
        selection.works.each do |work|
          next unless work.marc?

          marc_record = MarcRecord.find_by(folder: collection.key, doi: work.marc.doi)
          next unless marc_record
          next unless marc_record.selected

          log << "INFO: At least one MARC record in #{selection.name} has been updated."

          kbart_file.verified = false
          kbart_file.save!
          break
        end
      end

      # Log orphan KBART records a.k.a. previous records that no longer have a matching KBART csv file
      kbart_files.each do |kbart_file|
        log << "WARNING: KBART FILE NOT FOUND #{kbart_file.name}"
      end

      log
    end
  end
end
