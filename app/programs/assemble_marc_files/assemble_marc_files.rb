# frozen_string_literal: true

require 'digest/md5'

module AssembleMarcFiles
  class AssembleMarcFiles # rubocop:disable Metrics/ClassLength
    attr_accessor :errors

    def initialize(ftp_fulcrum_org)
      @ftp_fulcrum_org = ftp_fulcrum_org
      @errors = []
    end

    def assemble_marc_files(publisher, delta) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
      @errors = []
      log = []

      # Recursive remove tmp folder from last time
      FileUtils.rm_rf(publisher.key)
      # Create tmp folder
      Dir.mkdir(publisher.key)
      # Change working directory to tmp folder
      Dir.chdir(publisher.key) do
        publisher.collections.each do |collection|
          record = KbartFile.find_by(folder: publisher.key, name: collection.name)
          next unless record

          if record.updated < collection.updated || !record.verified
            record.updated = collection.updated
            record.verified = true
            recreate_collection_marc_files(record, collection)
            record.save!
          end
          create_collection_marc_delta_files(collection) if delta # && record.verified
        end
        recreate_publisher_marc_files(publisher) if publisher.collections.count > 1
        log = upload_marc_files(publisher)
      end

      log
    end

    def recreate_collection_marc_files(record, collection) # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
      filename = collection.name

      Rails.logger.info("AssembleMarcFiles::AssembleMarcFiles.recreate_collection_marc_files(#{record.name}, #{collection.name})")

      collection_works = {}
      collection.works.each do |work|
        if work.marc?
          kbart_marc = KbartMarc.find_or_create_by!(folder: collection.publisher.key, file: collection.name, doi: work.marc.doi)
          unless kbart_marc.updated
            kbart_marc.updated = collection.updated
            kbart_marc.save!
          end
          collection_works[work.doi.to_s] = work
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

    def create_collection_marc_delta_files(collection) # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
      prev_delta = 1.month.ago
      prev_delta_date = Date.new(prev_delta.year, prev_delta.month, 15)
      this_delta = Time.now
      this_delta_date = Date.new(this_delta.year, this_delta.month, 15)

      filename = "#{collection.name}_update_#{format('%04d-%02d-%02d', this_delta_date.year, this_delta_date.month, this_delta_date.day)}"

      Rails.logger.info("AssembleMarcFiles::AssembleMarcFiles.create_collection_delta_files(#{collection.name}) pathname: #{collection.pathname}")

      collection_works = {}
      collection.works.each do |work|
        next unless work.marc?

        kbart_marc = KbartMarc.find_by(folder: collection.publisher.key, file: collection.name, doi: work.marc.doi)
        if kbart_marc.nil?
          Rails.logger.error("Can't find KbarcMarc(folder: #{collection.publisher.key}, file: #{collection.name}, doi: #{work.marc.doi})")
          # Below causes an exception that gets eaten in the main AssembleMarcFiles.run (StandardError yikes) and then gets emailed to admistrators. 
          # And is causes the whole delta making process to crash without making any deltas.
          # We'll make do with the production.log here.
          # KbartMarc.find_by!(folder: collection.publisher.key, file: collection.name, doi: work.marc.doi)
        end

        next if kbart_marc.nil?

        collection_works[work.doi.to_s] = work if kbart_marc.updated > prev_delta_date && kbart_marc.updated <= this_delta_date
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

    def recreate_publisher_marc_files(publisher) # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
      filename = "#{publisher.name}_Complete"

      Rails.logger.info("AssembleMarcFiles::AssembleMarcFiles.recreate_publisher_marc_files(#{publisher.name}) file: #{filename}")

      if filename == "UMPEBC_Complete"
        Rails.logger.info("AssembleMarcFiles::AssembleMarcFiles.recreate_publisher_marc_files: SKIP CREATING #{filename})")
        return
      end

      publisher_works = {}
      publisher.collections.each do |collection|
        collection.works.each do |work|
          next unless work.marc?

          publisher_works[work.doi.to_s] = work
        end
      end

      return if publisher_works.empty?

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
      publisher_works.keys.sort.each do |key|
        work = publisher_works[key]
        xml_writer.write(work.marc.entry)
        writer.write(work.marc.entry)
      end
      xml_writer.close
      writer.close
    end

    def upload_marc_files(publisher) # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
      filenames = []
      Dir.entries(Dir.pwd).each do |entry|
        filename = entry.to_s
        next unless /^\.(mrc|xml)$/i.match?(File.extname(filename))

        marc_file = MarcFile.find_or_create_by!(folder: publisher.key, name: filename)
        checksum = Digest::MD5.hexdigest(File.read(filename))
        next if marc_file.checksum == checksum

        begin
          publisher.upload_marc_file(filename)
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
