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

    def marcs # rubocop:disable  Metrics/MethodLength, Metrics/AbcSize
      @marcs ||= begin
        marcs = []
        MarcRecord.where(folder: @collection.key).each do |marc_record|
          next unless marc_record.parsed

          begin
            marc = MARC::Reader.decode(marc_record.mrc, external_encoding: "UTF-8", validate_encoding: true)
            marcs << Unmarshaller::Marc.new(marc)
          rescue Encoding::InvalidByteSequenceError => e
            msg = "LibPtgBox::Catalog#marcs(id #{marc_record.id}, doi #{marc_record.doi}) #{e}"
            Rails.logger.error msg
            NotifierMailer.administrators("StandardError", msg).deliver_now
          end
        end
        marcs
      end
    end
  end
end
