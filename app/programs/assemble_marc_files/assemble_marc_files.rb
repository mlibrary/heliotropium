# frozen_string_literal: true

module AssembleMarcFiles
  class AssembleMarcFiles
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
      writer = MARC::Writer.new(filename + '.mrc')
      xml_writer = MARC::XMLWriter.new(filename + '.xml')
      selection.works.each do |work|
        if work.marc?
          writer.write(work.marc.entry)
          xml_writer.write(work.marc.entry)
          umpebc_marc = UmpebcMarc.find_or_create_by!(doi: work.marc.doi)
          umpebc_marc.mrc = work.marc.to_mrc
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
      writer.close
      xml_writer.close
    end

    def recreate_collection_month_marc_file(collection) # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
      collection.selections.each do |selection|
        next unless selection.year == Date.today.year

        month = Date.today.month
        filename = selection.name + format("-%02d", month)
        writer = MARC::Writer.new(filename + '.mrc')
        xml_writer = MARC::XMLWriter.new(filename + '.xml')
        umpebc_marcs = UmpebcMarc.where('year = ? AND updated_at >= ?', selection.year, DateTime.new(selection.year, month, 1))
        umpebc_marcs.each do |umpebc_marc|
          marc = MARC::Reader.decode(umpebc_marc.mrc, external_encoding: "UTF-8", validate_encoding: true)
          writer.write(marc)
          xml_writer.write(marc)
        end
        writer.close
        xml_writer.close
        break
      end
    end

    def recreate_collection_marc_files(collection) # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
      filename = collection.name + '_Complete'
      writer = MARC::Writer.new(filename + '.mrc')
      xml_writer = MARC::XMLWriter.new(filename + '.xml')
      collection.selections.each do |selection|
        selection.works.each do |work|
          next unless work.marc?

          writer.write(work.marc.entry)
          xml_writer.write(work.marc.entry)
        end
      end
      writer.close
      xml_writer.close
    end

    def upload_marc_files(collection)
      filenames = []
      Dir.entries(Dir.pwd).each do |filename|
        next unless /^.+\.(mrc|xml)$/.match?(filename)

        filenames << filename.to_s

        collection.upload_marc_file(filename)
      end

      filenames.sort.reverse
    end
  end
end
