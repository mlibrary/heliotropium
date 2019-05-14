# frozen_string_literal: true

module Cataloging
  class Cataloging
    def initialize(product)
      @product = product
    end

    def marc(doi)
      # Send Email Alert if Marc not found.

      Marc::Marc.new
    end
  end
end
