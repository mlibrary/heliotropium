# frozen_string_literal: true

module LibPtgBox
  module Unmarshaller
    class KbartFile < SimpleDelegator
      def kbarts
        @kbarts ||= begin
          kbarts = []
          skip = true
          content.each_line do |line|
            kbarts << Kbart.new(line) unless skip || line.length < 10
            skip = false
          end
          kbarts
        end
      end
    end
  end
end
