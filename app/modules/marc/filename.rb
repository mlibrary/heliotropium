# frozen_string_literal: true

module Marc
  class Filename
    attr_reader :filename, :name, :year, :ext, :base

    def initialize(filename) # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
      @filename = filename
      match = /(^.+)_(Complete)\.(.+$)/.match(@filename)
      if match
        @name = match[1]
        @year = ''
        @suffix = match[2]
        @ext = match[3]
        @base = @name + '_' + @suffix
      else
        match = /(^.+)_(OA)\.(.+$)/.match(@filename)
        if match
          @name = match[1]
          @year = ''
          @suffix = match[2]
          @ext = match[3]
          @base = @name + '_' + @suffix
        else
          match = /(^.+)_(\d{4})(.*)?\.(.+$)/.match(@filename)
          if match
            @name = match[1]
            @year = match[2]
            @suffix = match[3]
            @ext = match[4]
            @base = @name + '_' + @year + @suffix
          else
            @name = ''
            @year = ''
            @suffix = ''
            @ext = ''
            @base = ''
          end
        end
      end
    end

    def mrc?
      /mrc/i.match?(@ext)
    end

    def xml?
      /xml/i.match?(@ext)
    end

    def open_access?
      /^oa$/i.match?(@suffix)
    end

    def complete?
      /^complete$/i.match?(@suffix)
    end

    def monthly?
      match = /(^.*)(_\d{2}$)/.match(@suffix)
      match && match[2]
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
