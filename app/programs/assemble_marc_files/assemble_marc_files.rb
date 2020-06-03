# frozen_string_literal: true

require 'digest/md5'

module AssembleMarcFiles
  class AssembleMarcFiles # rubocop:disable Metrics/ClassLength
    attr_accessor :errors

    def initialize(lib_ptg_box)
      @lib_ptg_box = lib_ptg_box
      @errors = []
    end

    def assemble_marc_files(collection) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
      log = []

      # Recursive remove tmp folder from last time
      FileUtils.rm_rf(collection.key)
      # Create tmp folder
      Dir.mkdir(collection.key)
      # Change working directory to tmp folder
      Dir.chdir(collection.key) do
        collection.selections.each do |selection|
          record = KbartFile.find_by(folder: collection.key, name: selection.name, year: selection.year)
          next unless record
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
          kbart_marc = KbartMarc.find_or_create_by!(folder: selection.collection.key, doi: work.marc.doi)
          kbart_marc.year = selection.year
          kbart_marc.save!
        else
          record.verified = false
          errors << "#{filename} MISSING MARC Record"
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
        kbart_marcs = KbartMarc.where('folder = ? AND year = ? AND updated_at >= ?', collection.key, selection.year, DateTime.new(selection.year, month, 1))
        break if kbart_marcs.blank?

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
        kbart_marcs.each do |kbart_marc|
          marc = collection.catalog.marc(kbart_marc.doi)
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

        marc_file = MarcFile.find_or_create_by!(folder: collection.key, name: filename)
        checksum = Digest::MD5.hexdigest(File.read(filename))
        next if marc_file.checksum == checksum

        begin
          collection.upload_marc_file(filename)
          marc_file.checksum = checksum
          marc_file.save!
          filenames << filename.to_s
        rescue StandardError => e
          errors << "ERROR Uploading #{filename} #{e}"
        end
      end

      filenames.sort.reverse
    end
  end
end
