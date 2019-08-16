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

    def marcs # rubocop:disable Metrics/PerceivedComplexity, Metrics/MethodLength, Metrics/CyclomaticComplexity, Metrics/AbcSize
      @marcs ||= begin
        marcs = []
        @marc_folder.marc_files.each do |marc_file| # rubocop:disable Metrics/BlockLength
          next if /ump_ebc/i.match?(marc_file.name)
          next unless /.+\.mrc$/i.match?(marc_file.name)

          record = CatalogMarc.find_or_create_by!(folder: @marc_folder.name, file: marc_file.name, isbn: /(^\d+)(.*$)/.match(marc_file.name)[1])

          if record.updated < marc_file.updated || record.content.blank?
            record.updated = marc_file.updated
            record.content = marc_file.content
            record.save!
          end

          record.raw = nil
          record.count = 0
          count = 0
          reader = MARC::Reader.new(StringIO.new(record.content), external_encoding: "UTF-8", validate_encoding: true)
          reader.each_raw do |raw|
            record.raw = raw unless count.positive?
            count += 1
          end
          record.count = count
          record.save!

          Rails.logger.error("LibPtgBox::Catalog(#{@marc_folder.name})#marcs(#{marc_file.name}) no records!!!") if count < 1
          Rails.logger.error("LibPtgBox::Catalog(#{@marc_folder.name})#marcs(#{marc_file.name}) #{count} records!!!") if count > 1

          record.mrc = nil
          record.doi = nil
          record.parsed = false
          record.replaced = false
          if count.positive?
            begin
              record.mrc = reader.decode(record.raw)
              record.parsed = true
              marc = Unmarshaller::Marc.new(record.mrc)
              record.doi = marc.doi
              marcs << marc
            rescue Encoding::InvalidByteSequenceError => e
              Rails.logger.error("LibPtgBox::Catalog(#{@marc_folder.name})#marcs(#{marc_file.name}) #{e}")
              begin
                record.mrc = MARC::Reader.decode(record.raw, external_encoding: "UTF-8", invalid: :replace)
                record.parsed = true
                record.replaced = true
                marc = Unmarshaller::Marc.new(record.mrc)
                record.doi = marc.doi
                marcs << marc
              rescue StandardError => e
                Rails.logger.error("LibPtgBox::Catalog(#{@marc_folder.name})#marcs(#{marc_file.name}) #{e}")
              end
            rescue StandardError => e
              Rails.logger.error("LibPtgBox::Catalog(#{@marc_folder.name})#marcs(#{marc_file.name}) #{e}")
            end
          end
          record.save!
        end

        marcs
      end
    end
  end
end
