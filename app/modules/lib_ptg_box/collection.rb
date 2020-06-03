# frozen_string_literal: true

module LibPtgBox
  class Collection
    attr_reader :key
    attr_reader :mailers
    attr_reader :name

    def initialize(collection, sub_folder)
      @key = collection.key
      @mailers = collection.mailers
      @sub_folder = sub_folder
      match = /(^.+)(\sMetadata$)/i.match(sub_folder.name)
      @name = match.present? ? match[1] : sub_folder.name
    end

    def selections
      @selections ||= @sub_folder.kbart_folder.kbart_files.sort_by(&:name).reverse.map { |kbart_file| Selection.new(self, kbart_file) }
    end

    def upload_marc_file(filename)
      @sub_folder.upload_folder.delete(filename)
      @sub_folder.upload_folder.upload(filename)
    end

    def marc(doi)
      marcs.each do |marc|
        next unless /#{doi}/i.match?(marc.doi)

        return marc
      end
      nil
    end

    def marcs
      @marcs ||= begin
        complete_marc_file = nil
        @sub_folder.marc_folder.marc_files.each do |marc_file|
          next unless /complete\.mrc/i.match?(marc_file.name)

          complete_marc_file = marc_file
          break
        end
        complete_marc_file.marcs
      end
    end

    def catalog
      @catalog ||= Catalog.new(self, @sub_folder.cataloging_marc_folder)
    end
  end
end
