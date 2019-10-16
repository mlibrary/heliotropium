# frozen_string_literal: true

require 'marc'

module LibPtgBox
  class Catalog
    attr_reader :marc_folder

    def initialize(collection, marc_folder)
      @collection = collection
      @marc_folder = marc_folder
    end

    def marc(doi)
      marcs.each do |marc|
        next unless /#{doi}/i.match?(marc.doi)

        return marc
      end
      nil
    end

    def marcs # rubocop:disable  Metrics/MethodLength
      @marcs ||= begin
        marcs = []
        CatalogMarc.all.each do |catalog_marc|
          next unless catalog_marc.parsed && !catalog_marc.replaced

          begin
            marc = MARC::Reader.decode(catalog_marc.raw, external_encoding: "UTF-8", validate_encoding: true)
            marcs << Unmarshaller::Marc.new(marc)
          rescue Encoding::InvalidByteSequenceError => e
            Rails.logger.error("LibPtgBox::Catalog#marcs(id #{catalog_marc.id}, doi #{catalog_marc.doi}) #{e}")
          end
        end
        marcs
      end
    end
  end
end
