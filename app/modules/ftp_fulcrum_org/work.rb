# frozen_string_literal: true

module FtpFulcrumOrg
  class Work
    def initialize(collection, kbart)
      @collection = collection
      @kbart = kbart
    end

    delegate :doi, :print, :online, :title, :date, to: :@kbart

    def name
      doi
    end

    def url
      "https://doi.org/#{doi}"
    end

    def marc?
      !!marc
    end

    def marc
      @marc ||= @collection.publisher.catalog.marc(doi)
    end
  end
end
