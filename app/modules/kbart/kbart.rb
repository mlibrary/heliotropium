# frozen_string_literal: true

require 'csv'

module Kbart
  class Kbart
    def initialize(filename)
      @filename = filename
    end

    def dois # rubocop:disable Metrics/MethodLength
      rvalue = []
      File.open(@filename, 'r:utf-16le:utf-8') do |file|
        file.each_with_index do |line, index|
          next unless index.positive?

          begin
            CSV.parse(line) do |row|
              rvalue << row[11] # doi
            end
          rescue StandardError => e
            p "ERROR: " + @filename + ' ' + line + ' ' + e.to_s
          end
        end
      end
      rvalue
    end
  end
end
