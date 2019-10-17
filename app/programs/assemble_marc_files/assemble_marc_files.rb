# frozen_string_literal: true

module AssembleMarcFiles
  class AssembleMarcFiles
    attr_accessor :errors

    def initialize(lib_ptg_box)
      @lib_ptg_box = lib_ptg_box
      @errors = []
    end

    def execute
      # Loop through collections a.k.a. M | box - All Files > Library PTG Box folders e.g. UMPEBC Metadata, Lever Press Metadata
      @lib_ptg_box.collections.each do |collection|
        # Only process UMPEBC Metadata folder.
        next unless /umpebc/i.match?(collection.name)

        # Assemble MARC Files for UMPEBC collection
        assemble_marc_files(collection)
      end
    end

    def append_selection_month_marc_file(selection, month) # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
      filename = selection.name + format("-%02d", month)
      writer = MARC::Writer.new(filename + '.mrc')
      xml_writer = MARC::XMLWriter.new(filename + '.xml')
      selection.works.each do |work|
        next unless work.new?
        next unless work.marc?

        writer.write(work.marc.entry)
        xml_writer.write(work.marc.entry)
      end
      writer.close
      xml_writer.close
    end

    def recreate_selection_marc_files(record, selection) # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
      filename = selection.name
      writer = MARC::Writer.new(filename + '.mrc')
      xml_writer = MARC::XMLWriter.new(filename + '.xml')
      selection.works.each do |work|
        if work.marc?
          writer.write(work.marc.entry)
          xml_writer.write(work.marc.entry)
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
      Dir.entries(Dir.pwd).each do |filename|
        next unless /^.+\.(mrc|xml)$/.match?(filename)

        collection.upload_marc_file(filename)
      end
    end

    def assemble_marc_files(collection) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
      # Only process UMPEBC Metadata folder.
      return unless /umpebc/i.match?(collection.name)

      # Update selection if KBART csv file was updated since last time marc files where assembled
      update_selection = false
      collection.selections.each do |selection|
        record = UmpebcKbart.find_by(name: selection.name, year: selection.year)
        next unless record.updated < selection.updated || !record.verified

        update_selection = true
        break
      end

      # Return unless at least one KBART csv file has been updated since last time
      return unless update_selection

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
          append_selection_month_marc_file(selection, Date.today.month) if selection.year == Date.today.year
          recreate_selection_marc_files(record, selection)
          record.save!
        end
        recreate_collection_marc_files(collection)
        upload_marc_files(collection)
      end
    end
  end
end
