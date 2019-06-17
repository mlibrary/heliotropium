# frozen_string_literal: true

require 'marc'

module LibPtgBox
  class Catalog
    def initialize(collection, complete_marc_file)
      @collection = collection
      @complete_marc_file = complete_marc_file
    end

    def marc(doi)
      marcs.each do |marc|
        next unless /#{doi}/i.match?(marc.doi)

        return marc
      end
      nil
    end

    def marcs
      @marcs ||= @complete_marc_file.marcs
    end
  end
end
