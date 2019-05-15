# frozen_string_literal: true

module Kbart
  class Filename
    attr_reader :filename, :name, :year, :yyyy, :mm, :dd, :ext, :base

    def initialize(filename) # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
      @filename = filename
      match = /(^.+)_(\d{4})(.*)?_(\d{4})-(\d{2})-(\d{2})\.(.+$)/.match(@filename)
      if match
        @name = match[1]
        @year = match[2]
        @suffix = match[3]
        @yyyy = match[4]
        @mm = match[5]
        @dd = match[6]
        @ext = match[7]
        @base = @name + '_' + @year + @suffix
      else
        @name = ''
        @year = ''
        @suffix = ''
        @yyyy = ''
        @mm = ''
        @dd = ''
        @ext = ''
        @base = ''
      end
    end

    def csv?
      /csv/i.match?(@ext)
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
