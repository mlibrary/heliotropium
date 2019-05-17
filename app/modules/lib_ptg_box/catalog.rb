# frozen_string_literal: true

require 'marc'

module LibPtgBox
  class Catalog
    def initialize(product, complete_marc_file)
      @product = product
      @complete_marc_file = complete_marc_file
      @reader = MARC::XMLReader.new(StringIO.new(complete_marc_file.content))
      @marcs = @reader.entries.map { |entry| Unmarshaller::Marc.new(entry) }
    end

    def marc(doi)
      @marcs.each do |marc|
        next unless /#{doi}/i.match?(marc.doi)

        return marc
      end
      nil
    end
  end
end
