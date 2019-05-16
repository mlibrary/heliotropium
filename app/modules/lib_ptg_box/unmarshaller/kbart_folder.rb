# frozen_string_literal: true

module LibPtgBox
  module Unmarshaller
    class KbartFolder < SimpleDelegator
      def kbart_files
        @kbart_files ||= files.map { |file| KbartFile.new(file) }
      end
    end
  end
end
