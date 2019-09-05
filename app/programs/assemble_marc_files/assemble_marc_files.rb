# frozen_string_literal: true

module AssembleMarcFiles
  class AssembleMarcFiles # rubocop:disable Metrics/ClassLength
    attr_accessor :errors

    def initialize
      @errors = []
    end

    def execute(reset = false) # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
      # Destroying all the UmpebcKbart records will force reassembly of all MARC files.
      UmpebcKbart.destroy_all if reset

      # Create/Change tmp working directory
      chdir_lib_ptg_box_dir

      # Object wrapper for M | box - All Files > Library PTG Box
      lib_ptg_box = LibPtgBox::LibPtgBox.new

      # Synchronize UmpebcKbart table with M | box - All Files > Library PTG Box > UMPEBC Metadata > UMPEBC KBART folder
      synchronize(lib_ptg_box)

      # Loop through collections a.k.a. M | box - All Files > Library PTG Box folders e.g. UMPEBC Metadata, Lever Press Metadata
      lib_ptg_box.collections.each do |collection|
        # Only process UMPEBC Metadata folder.
        next unless /umpebc/i.match?(collection.name)

        # Assemble MARC Files for UMPEBC collection
        assemble_marc_files(collection)
      end

      # Cataloging Errors
      CatalogMarc.where(replaced: true).each do |record|
        errors << "INVALID UTF-8 encoding for #{record.folder} > #{record.file} https://doi.org/#{record.doi}"
        upper = MARC::Reader.decode(record.raw, external_encoding: "UTF-8", invalid: :replace, replace: 'Z')
        lower = MARC::Reader.decode(record.raw, external_encoding: "UTF-8", invalid: :replace, replace: 'z')
        upper.fields.each_with_index do |upper_field, index|
          lower_field = lower.fields[index]
          upper_set = upper_field.to_s.split(/\s/).to_set
          lower_set = lower_field.to_s.split(/\s/).to_set
          difference = upper_set ^ lower_set
          errors << "field #{upper_field.tag} #{difference}" unless difference.empty?
        end
      end
    end

    def synchronize(lib_ptg_box) # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
      lib_ptg_box.collections.each do |collection|
        # Only process UMPEBC Metadata folder.
        next unless /umpebc/i.match?(collection.name)

        # Previous KBART records list
        umpebc_kbarts = []
        UmpebcKbart.all.each do |umpebc_kbart|
          umpebc_kbarts << umpebc_kbart
        end

        # Find or create a record for each KBART csv file
        collection.selections.each do |selection|
          umpebc_kbart = UmpebcKbart.find_or_create_by!(name: selection.name, year: selection.year)
          # Remove record from the previous records list
          umpebc_kbarts.delete(umpebc_kbart) if umpebc_kbarts.include?(umpebc_kbart)
        end

        # Destroy orphan KBART records a.k.a. previous records that no longer have a matching KBART csv file
        umpebc_kbarts.each(&:destroy!)
      end
    end

    def append_selection_month_marc_file(selection, month) # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
      filename = selection.name + format("-%02d", month)
      mrc_file = File.open(filename + '.mrc', 'w')
      xml_file = File.open(filename + '.xml', 'w')
      selection.works.each do |work|
        next unless work.new?

        if work.marc?
          mrc_file << work.marc.to_marc
          xml_file << work.marc.to_xml
          xml_file << "\n"
        else
          errors << "MISSING Cataloging MARC record for https://doi.org/#{work.doi} in selection #{filename} of collection #{selection.collection.name}"
        end
      end
      mrc_file.close
      xml_file.close
    end

    def recreate_selection_marc_files(record, selection) # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
      filename = selection.name
      mrc_file = File.open(filename + '.mrc', 'w')
      xml_file = File.open(filename + '.xml', 'w')
      selection.works.each do |work|
        if work.marc?
          mrc_file << work.marc.to_marc
          xml_file << work.marc.to_xml
          xml_file << "\n"
        else
          record.verified = false
          errors << "MISSING Cataloging MARC record for https://doi.org/#{work.doi} in selection #{filename} of collection #{selection.collection.name}"
        end
      end
      mrc_file.close
      xml_file.close
    end

    def recreate_collection_marc_files(collection) # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
      entries = Dir.entries(Dir.pwd)
      filename = collection.name + '_Complete'
      mrc_file = File.open(filename + '.mrc', 'wb')
      xml_file = File.open(filename + '.xml', 'wb')
      entries.each do |marc_filename|
        next if /^.+-\d{2}\....$/.match?(marc_filename)
        next unless /^.+_\d{4}.*\....$/.match?(marc_filename)

        if /^.+\.mrc$/.match?(marc_filename)
          mrc_file.write(File.open(marc_filename, 'rb').read)
        elsif /^.+\.xml$/.match?(marc_filename)
          xml_file.write(File.open(marc_filename, 'rb').read)
        end
      end
      mrc_file.close
      xml_file.close
    end

    def upload_marc_files(collection)
      Dir.entries(Dir.pwd).each do |filename|
        next unless /^.+\.(mrc|xml)$/.match?(filename)

        collection.upload_marc_file(filename)
      end
    end

    def assemble_marc_files(collection) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength, Metrics/CyclomaticComplexity
      # Only process UMPEBC Metadata folder.
      return unless /umpebc/i.match?(collection.name)

      # Update selection if KBART csv file was updated since last time marc files where assembled
      update_selection = false
      collection.selections.each do |selection|
        record = UmpebcKbart.find_by(name: selection.name, year: selection.year)
        next unless record.updated < selection.updated

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
