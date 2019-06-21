# frozen_string_literal: true

module AssembleMarcFiles
  class AssembleMarcFiles # rubocop:disable Metrics/ClassLength
    def execute
      log = +''
      chdir_lib_ptg_box_dir
      lib_ptg_box = LibPtgBox::LibPtgBox.new
      log += reset
      log += synchronize(lib_ptg_box)
      lib_ptg_box.collections.each do |collection|
        # Only process UMPEBC Metadata folder.
        next unless /umpebc/i.match?(collection.name)

        log += assemble_marc_files(collection)
      end
      log
    end

    def reset
      log = +''
      UmpebcKbart.destroy_all
      log
    end

    def synchronize(lib_ptg_box) # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
      log = +''
      lib_ptg_box.collections.each do |collection|
        # Only process UMPEBC Metadata folder.
        next unless /umpebc/i.match?(collection.name)

        umpebc_kbarts = []
        UmpebcKbart.all.each do |umpebc_kbart|
          umpebc_kbarts << umpebc_kbart
        end

        collection.selections.each do |selection|
          umpebc_kbart = UmpebcKbart.find_or_create_by!(name: selection.name, year: selection.year)
          umpebc_kbarts.delete(umpebc_kbart) if umpebc_kbarts.include?(umpebc_kbart)
        end

        umpebc_kbarts.each(&:destroy!)
      end
      log
    end

    def append_selection_month_marc_file(selection, month) # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
      log = +''
      filename = selection.name + format("-%02d", month)
      mrc_file = File.open(filename + '.mrc', 'w')
      xml_file = File.open(filename + '.xml', 'w')
      selection.works.each do |work|
        next unless work.new?

        if work.marc?
          mrc_file << work.marc.to_marc
          xml_file << work.marc.to_xml
          xml_file << "\n"
          log += "Catalog MARC record for work '#{work.name}' in selection '#{selection.name}' in collection '#{selection.collection.name}' is new!\n"
        else
          log += "Catalog MARC record for work '#{work.name}' in selection '#{selection.name}' in collection '#{selection.collection.name}' is missing!\n"
        end
      end
      mrc_file.close
      xml_file.close
      log
    end

    def recreate_selection_marc_files(selection) # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
      log = +''
      filename = selection.name
      mrc_file = File.open(filename + '.mrc', 'w')
      xml_file = File.open(filename + '.xml', 'w')
      selection.works.each do |work|
        if work.marc?
          mrc_file << work.marc.to_marc
          xml_file << work.marc.to_xml
          xml_file << "\n"
        else
          log += "Catalog MARC record for work '#{work.name}' in selection '#{selection.name}' in collection '#{selection.collection.name}' is missing!\n"
        end
      end
      mrc_file.close
      xml_file.close
      log
    end

    def recreate_collection_marc_files(collection) # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
      log = +''
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
      log
    end

    def upload_marc_files(collection)
      log = +''
      Dir.entries(Dir.pwd).each do |filename|
        next unless /^.+\.(mrc|xml)$/.match?(filename)

        collection.upload_marc_file(filename)
      end
      log
    end

    def assemble_marc_files(collection) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
      log = +''
      # Only process UMPEBC Metadata folder.
      return log unless /umpebc/i.match?(collection.name)

      update_selection = false
      collection.selections.each do |selection|
        record = UmpebcKbart.find_by(name: selection.name, year: selection.year)
        next unless record.updated < selection.updated

        update_selection = true
        break
      end
      return log unless update_selection

      FileUtils.rm_rf('umpebc')
      Dir.mkdir('umpebc')
      Dir.chdir('umpebc') do
        collection.selections.each do |selection|
          record = UmpebcKbart.find_by(name: selection.name, year: selection.year)
          if record.updated < selection.updated
            log += append_selection_month_marc_file(selection, Date.today.month) if selection.year == Date.today.year
            log += recreate_selection_marc_files(selection)
            record.updated = selection.updated
            record.save
          else
            log += recreate_selection_marc_files(selection)
          end
        end
        log += recreate_collection_marc_files(collection)
        log += upload_marc_files(collection)
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
