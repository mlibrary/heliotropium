# frozen_string_literal: true

module LibPtgBox
  module Unmarshaller
    class KbartFolder < SimpleDelegator
      def kbart_files
        return @kbart_files if @kbart_files.present?

        @kbart_files = []
        files.each do |file|
          next unless /\.csv/i.match?(file.extension)

          @kbart_files << KbartFile.new(file)
        end
        @kbart_files
      end
    end
  end
end
