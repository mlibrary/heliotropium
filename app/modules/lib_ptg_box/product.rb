# frozen_string_literal: true

module LibPtgBox
  class Product
    attr_reader :product_family, :name, :year, :yyyy, :mm, :dd

    def initialize(product_family, kbart_file) # rubocop:disable Metrics/AbcSize
      @product_family = product_family
      @kbart_file = kbart_file
      match = /(^.+)_(\d{4})(.*)?_(\d{4})-(\d{2})-(\d{2})\.(.+$)/.match(@kbart_file.name)
      @name = match[1] + '_' + match[2] + match[3]
      @year = match[2]
      @suffix = match[3]
      @yyyy = match[4]
      @mm = match[5]
      @dd = match[6]
    end

    def works
      @works ||= @kbart_file.kbarts.map { |kbart| Work.new(self, kbart) }
    end

    def year?
      /#{@year}/.match?(format("%04d", Time.now.year))
    end

    def modified_today?
      modified_this_year? && modified_this_month? && /#{@dd}/.match?(format("%02d", Time.now.day))
    end

    def modified_this_month?
      modified_this_year? && /#{@mm}/.match?(format("%02d", Time.now.month))
    end

    def modified_this_year?
      /#{@yyyy}/.match?(format("%04d", Time.now.year))
    end
  end
end
