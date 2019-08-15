# frozen_string_literal: true

require 'marc'

module LibPtgBox
  class Catalog
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

    def marcs
      @marcs ||= begin
        marcs = []
        @marc_folder.marc_files.each do |marc_file|
          next if /ump_ebc/i.match?(marc_file.name)
          next unless /.+\.mrc$/i.match?(marc_file.name)

          record = CatalogMarc.find_or_create_by!(folder: @marc_folder.name, file: marc_file.name)

          if record.updated < marc_file.updated || !record.parsed || true
            record.parsed = false
            record.updated = marc_file.updated
            record.isbn = /(^\d+)(.*$)/.match(marc_file.name)[1]
            if marc_file.marcs.count.positive?
              Rails.logger.error("LibPtgBox::Catalog(#{@marc_folder.name})#marcs(#{marc_file.name}) #{marc_file.marcs.count} records!!!") if marc_file.marcs.count > 1
              record.mrc = marc_file.marcs.first.to_marc
              record.doi = marc_file.marcs.first.doi
              record.parsed = true
            else
              Rails.logger.error("LibPtgBox::Catalog(#{@marc_folder.name})#marcs(#{marc_file.name}) empty!!!") if marc_file.marcs.empty?
            end
            record.save!
          end

          marcs << Unmarshaller::Marc.new(MARC::Reader.new(StringIO.new(record.mrc)).entries.first) if record.parsed
        end
        marcs
      end
    end
  end
end
