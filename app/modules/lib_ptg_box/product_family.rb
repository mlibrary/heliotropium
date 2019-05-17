# frozen_string_literal: true

module LibPtgBox
  class ProductFamily
    attr_reader :name

    def initialize(family_folder)
      @family_folder = family_folder
      @name = family_folder.name
    end

    def products
      @products ||= @family_folder.kbart_folder.kbart_files.map { |kbart_file| Product.new(self, kbart_file) }
    end

    def catalog
      @catalog ||= begin
        complete_marc_file = nil
        @family_folder.cataloging_marc_folder.marc_files.each do |marc_file|
          next unless /complete\.xml/i.match?(marc_file.name)

          complete_marc_file = marc_file
          break
        end
        Catalog.new(self, complete_marc_file)
      end
    end
  end
end
