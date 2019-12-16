# frozen_string_literal: true

require 'digest/md5'

module AssembleMarcFiles
  class AssembleMarcFiles # rubocop:disable Metrics/ClassLength
    attr_accessor :errors

    def initialize(lib_ptg_box)
      @lib_ptg_box = lib_ptg_box
      @errors = []
    end

    def execute
      log = []

      # Loop through collections a.k.a. M | box - All Files > Library PTG Box folders e.g. UMPEBC Metadata, Lever Press Metadata
      @lib_ptg_box.collections.each do |collection|
        # Only process UMPEBC Metadata folder.
        next unless /umpebc/i.match?(collection.name)

        # Assemble MARC Files for UMPEBC collection
        log = assemble_marc_files(collection)
      end

      log
    end

    def assemble_marc_files(collection) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
      # Only process UMPEBC Metadata folder.
      return [] unless /umpebc/i.match?(collection.name)

      log = []

      # Recursive remove tmp folder from last time
      FileUtils.rm_rf('umpebc')
      # Create tmp folder
      Dir.mkdir('umpebc')
      # Change working directory to tmp folder
      Dir.chdir('umpebc') do
        collection.selections.each do |selection|
          record = UmpebcKbart.find_by(name: selection.name, year: selection.year)
          next unless record.updated < selection.updated || !record.verified

          record.updated = selection.updated
          record.verified = true
          recreate_selection_marc_files(record, selection)
          record.save!
        end
        recreate_collection_month_marc_file(collection)
        recreate_collection_marc_files(collection)
        log = upload_marc_files(collection)
      end

      log
    end

    def recreate_selection_marc_files(record, selection) # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
      filename = selection.name

      # Danger Will Robinson! Danger Will Robinson!
      #
      # Bill Dueber:vomit_frog: 16:51
      # Figured it out. MARC-XML doesn't allow non-alphanumerics in the leader by spec,
      # so the MARC::XMLWriter turns them into Zs. So you get a '?' in the original marc,
      # which gets writen to the .marc file. Then the xml writer changes the leader before
      # it writes it out. So when you repeat, you get the change.
      #
      # The "solution", I guess, is to write the XML file out first,
      # but I'd document the @^%& out of it.

      xml_writer = MARC::XMLWriter.new(filename + '.xml')
      writer = MARC::Writer.new(filename + '.mrc')
      selection.works.each do |work|
        if work.marc?
          xml_writer.write(work.marc.entry)
          writer.write(work.marc.entry)
          umpebc_marc = UmpebcMarc.find_or_create_by!(doi: work.marc.doi)
          umpebc_marc.year = selection.year
          umpebc_marc.save!
        else
          record.verified = false
          errors << "#{filename} MISSING Cataloging MARC record"
          errors << work.url.to_s
          errors << "#{work.title} (#{work.date})"
          errors << "#{work.print} (print)"
          errors << "#{work.online} (online)"
          errors << ""
        end
      end
      xml_writer.close
      writer.close
    end

    def recreate_collection_month_marc_file(collection) # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
      collection.selections.each do |selection|
        next unless selection.year == Date.today.year

        month = Date.today.month
        filename = selection.name + format("-%02d", month)
        umpebc_marcs = UmpebcMarc.where('year = ? AND updated_at >= ?', selection.year, DateTime.new(selection.year, month, 1))
        break if umpebc_marcs.blank?

        # Danger Will Robinson! Danger Will Robinson!
        #
        # Bill Dueber:vomit_frog: 16:51
        # Figured it out. MARC-XML doesn't allow non-alphanumerics in the leader by spec,
        # so the MARC::XMLWriter turns them into Zs. So you get a '?' in the original marc,
        # which gets writen to the .marc file. Then the xml writer changes the leader before
        # it writes it out. So when you repeat, you get the change.
        #
        # The "solution", I guess, is to write the XML file out first,
        # but I'd document the @^%& out of it.

        xml_writer = MARC::XMLWriter.new(filename + '.xml')
        writer = MARC::Writer.new(filename + '.mrc')
        umpebc_marcs.each do |umpebc_marc|
          marc = collection.catalog.marc(umpebc_marc.doi)
          xml_writer.write(marc.entry)
          writer.write(marc.entry)
        end
        xml_writer.close
        writer.close
        break
      end
    end

    def recreate_collection_marc_files(collection) # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
      filename = collection.name + '_Complete'

      # Danger Will Robinson! Danger Will Robinson!
      #
      # Bill Dueber:vomit_frog: 16:51
      # Figured it out. MARC-XML doesn't allow non-alphanumerics in the leader by spec,
      # so the MARC::XMLWriter turns them into Zs. So you get a '?' in the original marc,
      # which gets writen to the .marc file. Then the xml writer changes the leader before
      # it writes it out. So when you repeat, you get the change.
      #
      # The "solution", I guess, is to write the XML file out first,
      # but I'd document the @^%& out of it.

      xml_writer = MARC::XMLWriter.new(filename + '.xml')
      writer = MARC::Writer.new(filename + '.mrc')
      collection.selections.each do |selection|
        selection.works.each do |work|
          next unless work.marc?

          xml_writer.write(work.marc.entry)
          writer.write(work.marc.entry)
        end
      end
      xml_writer.close
      writer.close
    end

    def upload_marc_files(collection) # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
      filenames = []
      Dir.entries(Dir.pwd).each do |entry|
        filename = entry.to_s
        next unless /^.+\.(mrc|xml)$/.match?(filename)

        umpebc_file = UmpebcFile.find_or_create_by!(name: filename)
        checksum = Digest::MD5.hexdigest(File.read(filename))
        next if umpebc_file.checksum == checksum

        begin
          collection.upload_marc_file(filename)
          umpebc_file.checksum = checksum
          umpebc_file.save!
          filenames << filename.to_s
        rescue StandardError => e
          errors << "ERROR Uploading #{filename} #{e}"
        end
      end

      filenames.sort.reverse
    end
  end
end
