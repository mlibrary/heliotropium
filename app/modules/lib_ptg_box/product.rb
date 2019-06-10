# frozen_string_literal: true

module LibPtgBox
  class Selection
    attr_reader :collection, :name, :year, :updated

    def initialize(product_family, kbart_file)
      @product_family = product_family
      @kbart_file = kbart_file
      match = /(^.+)_(\d{4}-\d{2}-\d{2})\.(.+$)/.match(@kbart_file.name)
      @name = match[1]
      @updated = Date.parse(match[2])
      match = /(^.+)_(\d{4})(.*$)/.match(@name)
      @year = match[2].to_i
    end

    def works
      @works ||= @kbart_file.kbarts.map { |kbart| Work.new(self, kbart) }
    end
  end
end
