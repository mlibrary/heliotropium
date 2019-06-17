# frozen_string_literal: true

module LibPtgBox
  class Work
    attr_reader :doi

    def initialize(selection, kbart)
      @selection = selection
      @kbart = kbart
      @doi = kbart.doi
    end

    def name
      @doi
    end

    def new?
      if marc?
        !!!@selection.collection.marc(@doi) # rubocop:disable Style/DoubleNegation
      else
        false
      end
    end

    def marc?
      !!marc # rubocop:disable Style/DoubleNegation
    end

    def marc
      @marc ||= @selection.collection.catalog.marc(@doi)
    end
  end
end
