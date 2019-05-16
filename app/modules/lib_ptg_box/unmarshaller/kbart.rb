# frozen_string_literal: true

require 'csv'

module LibPtgBox
  module Unmarshaller
    class Kbart
      def initialize(line)
        @line = line.force_encoding('UTF-16BE').encode('UTF-8')
        begin
          CSV.parse(@line) do |row|
            @row = row
          end
        rescue StandardError => e
          Rails.logger.error("LibPtgBox::Unmarshaller::Kbart.initialize(#{@line}) error " + e.to_s)
          @row = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, "10.3998/mpub.00000000"]
        end
      end

      def doi
        @doi ||= @row[11]
      end
    end
  end
end
