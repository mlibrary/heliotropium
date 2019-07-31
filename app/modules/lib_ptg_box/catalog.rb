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

          marcs |= marc_file.marcs

          Rails.logger.error("LibPtgBox::Catalog(#{@marc_folder.name})#marcs(#{marc_file.name}) empty!!!") if marc_file.marcs.empty?
        end
        marcs
      end
    end
  end
end
