# frozen_string_literal: true

module AssembleMarcFiles
  class AssembleMarcFiles
    def execute
      log = +''
      lib_ptg_box = LibPtgBox::LibPtgBox.new
      log += synchronize(lib_ptg_box)
      lib_ptg_box.collections.each do |collection|
        # Only process UMPEBC Metadata folder.
        next unless /umpebc/i.match?(collection.name)

        log += assemble_marc_files(collection)
      end
      log
    end

    def synchronize(lib_ptg_box) # rubocop:disable Metrics/AbcSize
      log = +''
      lib_ptg_box.collections.each do |collection|
        # Only process UMPEBC Metadata folder.
        next unless /umpebc/i.match?(collection.name)

        collection.selections.each do |selection|
          record = LibPtgFolder.find_or_create_by!(name: selection.name)
          log += record.id.to_s + " " + collection.name + " " + selection.name + "\n"
          puts record.inspect
        end
      end
      log
    end

    def assemble_marc_files(collection)
      log = +''
      log += collection.name + "\n"
      log
    end

    # def run
    #   umpebc_collections_modified.each do |modified_collection|
    #     generate_collection_marc_files(modified_collection)
    #   end
    # rescue StandardError => e
    #   text = <<~MSG
    #   AssembleMarcFiles run error (#{e})
    #   MSG
    #   NotifierMailer.administrators(text).deliver_now
    # end
    #
    # private
    #
    # def generate_collection_marc_files(collection)
    #   collection.dois.each do |doi|
    #   end
    # end
    #
    # def umpebc_collections_modified
    #   umpebc_collection.collections.map { |collection| collection if collection.modified? }.compact
    # end
    #
    # def umpebc_collection
    #   @umpebc_collection ||= begin
    #     collections = LibPtgBox::LibPtgBox.new.collections
    #     umpebc_family = nil
    #     collections.each do |family|
    #       next unless /umpebc/i.match?(family.name)
    #
    #       umpebc_family = family
    #       break
    #     end
    #     raise 'umpebc collection family not found' unless umpebc_family
    #
    #     umpebc_family
    #   end
    # end
  end
end
