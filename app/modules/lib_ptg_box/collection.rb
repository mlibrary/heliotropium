# frozen_string_literal: true

module LibPtgBox
  class Collection
    attr_reader :name

    def initialize(sub_folder)
      @sub_folder = sub_folder
      @name = sub_folder.name
    end

    def selections
      @selections ||= @sub_folder.kbart_folder.kbart_files.map { |kbart_file| Selection.new(self, kbart_file) }
    end

    def upload_marc_file(_filename)
      ''
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
          next unless /complete\.xml/i.match?(marc_file.name)

          complete_marc_file = marc_file
          break
        end
        complete_marc_file.marcs
      end
    end

    def catalog
      @catalog ||= begin
        complete_marc_file = nil
        @sub_folder.cataloging_marc_folder.marc_files.each do |marc_file|
          next unless /complete\.xml/i.match?(marc_file.name)

          complete_marc_file = marc_file
          break
        end
        Catalog.new(self, complete_marc_file)
      end
    end
  end
end
