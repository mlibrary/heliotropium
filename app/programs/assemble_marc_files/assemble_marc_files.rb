# frozen_string_literal: true

require 'digest/md5'

module AssembleMarcFiles
  class AssembleMarcFiles # rubocop:disable Metrics/ClassLength
    attr_accessor :errors

    def initialize(lib_ptg_box)
      @lib_ptg_box = lib_ptg_box
      @errors = []
    end

    def assemble_marc_files(collection, delta) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
      @errors = []
      log = []

      # Recursive remove tmp folder from last time
      FileUtils.rm_rf(collection.key)
      # Create tmp folder
      Dir.mkdir(collection.key)
      # Change working directory to tmp folder
      Dir.chdir(collection.key) do
        collection.selections.each do |selection|
          record = KbartFile.find_by(folder: collection.key, name: selection.name)
          next unless record

          if record.updated < selection.updated || !record.verified
            record.updated = selection.updated
            record.verified = true
            recreate_selection_marc_files(record, selection)
            record.save!
          end
          create_selection_marc_delta_files(selection) if delta # && record.verified
        end
        recreate_collection_marc_files(collection) if collection.selections.count > 1
        log = upload_marc_files(collection)
      end

      log
    end

    def recreate_selection_marc_files(record, selection) # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
      filename = selection.name

      selection_works = {}
      selection.works.each do |work|
        if work.marc?
          kbart_marc = KbartMarc.find_or_create_by!(folder: selection.collection.key, file: selection.name, doi: work.marc.doi)
          unless kbart_marc.updated
            kbart_marc.updated = selection.updated
            kbart_marc.save!
          end
          selection_works[work.doi.to_s] = work
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

      return if selection_works.empty?

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

      xml_writer = MARC::XMLWriter.new("#{filename}.xml")
      writer = MARC::Writer.new("#{filename}.mrc")
      selection_works.keys.sort.each do |key|
        work = selection_works[key]
        xml_writer.write(work.marc.entry)
        writer.write(work.marc.entry)
      end
      xml_writer.close
      writer.close
    end

    def create_selection_marc_delta_files(selection) # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
      prev_delta = 1.month.ago
      prev_delta_date = Date.new(prev_delta.year, prev_delta.month, 15)
      this_delta = Time.now
      this_delta_date = Date.new(this_delta.year, this_delta.month, 15)

      filename = "#{selection.name}_update_#{format('%04d-%02d-%02d', this_delta_date.year, this_delta_date.month, this_delta_date.day)}"

      selection_works = {}
      selection.works.each do |work|
        next unless work.marc?

        kbart_marc = KbartMarc.find_by!(folder: selection.collection.key, file: selection.name, doi: work.marc.doi)
        selection_works[work.doi.to_s] = work if kbart_marc.updated > prev_delta_date && kbart_marc.updated <= this_delta_date
      end

      return if selection_works.empty?

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

      xml_writer = MARC::XMLWriter.new("#{filename}.xml")
      writer = MARC::Writer.new("#{filename}.mrc")
      selection_works.keys.sort.each do |key|
        work = selection_works[key]
        xml_writer.write(work.marc.entry)
        writer.write(work.marc.entry)
      end
      xml_writer.close
      writer.close
    end

    def recreate_collection_marc_files(collection) # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
      filename = "#{collection.name}_Complete"

      collection_works = {}
      collection.selections.each do |selection|
        selection.works.each do |work|
          next unless work.marc?

          collection_works[work.doi.to_s] = work
        end
      end

      return if collection_works.empty?

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

      xml_writer = MARC::XMLWriter.new("#{filename}.xml")
      writer = MARC::Writer.new("#{filename}.mrc")
      collection_works.keys.sort.each do |key|
        work = collection_works[key]
        xml_writer.write(work.marc.entry)
        writer.write(work.marc.entry)
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
