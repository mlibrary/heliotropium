# frozen_string_literal: true

module FtpFulcrumOrg
  class FtpFulcrumOrg
    def initialize(sftp)
      @sftp = sftp
      # WARNING Instance sets pwd to ./tmp/ftp_fulcrum_org and then assumes complete control of changing the pwd at will!!!
      ::FtpFulcrumOrg.chdir_ftp_fulcrum_org_dir
    end

    def publishers
      @publishers ||= Settings.ftp_fulcrum_org.publishers.map { |publisher| Publisher.new(@sftp, publisher) }
    end

    def synchronize_marc_records(publisher) # rubocop:disable Metrics/MethodLength, Metrics/AbcSize, Metrics/PerceivedComplexity, Metrics/CyclomaticComplexity
      log = []

      # Previous MARC records list
      db_marc_records = []
      ::MarcRecord.where("folder = ?", publisher.key).each do |db_marc_record|
        db_marc_records << db_marc_record
      end

      # Find or create a record for each MARC mrc/xml file (NOTE: Assumes 1:1 between record and file)
      publisher.catalog.marc_files.each do |marc_file| # rubocop:disable Metrics/BlockLength
        db_marc_record = ::MarcRecord.find_or_create_by!(folder: publisher.key, file: marc_file.name)

        # Clear selected flag. The selected flag will be set later if the record is updated.
        if db_marc_record.selected
          db_marc_record.selected = false
          db_marc_record.save!
        end

        if db_marc_record.updated < marc_file.updated || db_marc_record.content.blank? || db_marc_record.mrc.blank? || db_marc_record.count != 1 || !db_marc_record.parsed?
          begin
            db_marc_record.selected = true
            db_marc_record.updated = marc_file.updated
            db_marc_record.content = marc_file.content
            reader = if /.+\.mrc$/i.match?(marc_file.name)
                       MARC::Reader.new(StringIO.new(db_marc_record.content), external_encoding: "UTF-8", validate_encoding: true)
                     else
                       MARC::XMLReader.new(StringIO.new(db_marc_record.content))
                     end
            count = 0
            reader.each do |mrc|
              unless count.positive?
                db_marc_record.mrc = mrc.to_marc
                db_marc_record.doi = Marc.new(mrc).doi
              end
              count += 1
            end
            db_marc_record.count = count
            db_marc_record.parsed = count.positive?
            db_marc_record.save!
            log << "INFO: MARC Record updated in #{db_marc_record.folder} > #{db_marc_record.file}"
            log << "ERROR: NO MARC Record in #{db_marc_record.folder} > #{db_marc_record.file} record count = #{count}" if count < 1
            log << "WARNING: MULTIPLE MARC Records in #{db_marc_record.folder} > #{db_marc_record.file} record count = #{count}" if count > 1
          rescue StandardError => e
            log << "ERROR: #{e} reading MARC Record in #{db_marc_record.folder} > #{db_marc_record.file}"
            db_marc_record.selected = false
            db_marc_record.updated = Time.new(1970, 1, 1, 0, 0, 0, 0)
            db_marc_record.content = nil
            db_marc_record.mrc = nil
            db_marc_record.doi = nil
            db_marc_record.count = 0
            db_marc_record.parsed = false
            db_marc_record.save!
          end
        end

        # Remove record from the previous records list
        db_marc_records.delete(db_marc_record) if db_marc_records.include?(db_marc_record)
      end

      # Log orphan MARC records a.k.a. previous records that no longer have a matching MARC file
      db_marc_records.each do |db_marc_record|
        log << "WARNING: MARC FILE NOT FOUND #{db_marc_record.folder} > #{db_marc_record.file}"
      end

      log
    end

    def synchronize_kbart_files(publisher) # rubocop:disable Metrics/MethodLength, Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
      log = []

      # Previous KBART records list
      db_kbart_files = []
      ::KbartFile.where("folder = ?", publisher.key).each do |db_kbart_file|
        db_kbart_files << db_kbart_file
      end

      # Find or create a record for each KBART csv file
      publisher.collections.each do |collection|
        db_kbart_file = ::KbartFile.find_or_create_by!(folder: publisher.key, name: collection.name)
        # Remove record from the previous records list
        db_kbart_files.delete(db_kbart_file) if db_kbart_files.include?(db_kbart_file)
        next unless db_kbart_file.verified

        # Falsify verified KBART records that are dependent upon any updated (a.k.a. selected) MARC records
        collection.works.each do |work|
          next unless work.marc?

          db_marc_record = ::MarcRecord.find_by(folder: publisher.key, doi: work.marc.doi)
          next unless db_marc_record
          next unless db_marc_record.selected

          log << "INFO: At least one MARC record in #{collection.name} has been updated."

          db_kbart_file.verified = false
          db_kbart_file.save!
          break
        end
      end

      # Log orphan KBART records a.k.a. previous records that no longer have a matching KBART csv file
      db_kbart_files.each do |db_kbart_file|
        log << "WARNING: KBART FILE NOT FOUND #{db_kbart_file.name}"
      end

      log
    end
  end
end
