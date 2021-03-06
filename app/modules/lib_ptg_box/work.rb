# frozen_string_literal: true

module LibPtgBox
  class Work
    attr_reader :doi, :print, :online, :title, :date

    def initialize(selection, kbart)
      @selection = selection
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
      @marc ||= @selection.collection.catalog.marc(doi)
    end
  end
end
