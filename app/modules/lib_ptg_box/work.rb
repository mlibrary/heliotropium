# frozen_string_literal: true

module LibPtgBox
  class Work
    attr_reader :doi

    def initialize(product, kbart)
      @product = product
      @kbart = kbart
      @doi = kbart.doi
    end

    def marc?
      !!marc # rubocop:disable Style/DoubleNegation
    end

    def marc
      @marc ||= @product.product_family.catalog.marc(@doi)
    end
  end
end
