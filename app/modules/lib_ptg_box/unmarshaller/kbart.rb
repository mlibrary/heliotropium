# frozen_string_literal: true

require 'csv'

module LibPtgBox
  module Unmarshaller
    class Kbart
      def initialize(line)
        @line = encode_line(line)
        begin
          CSV.parse(@line) do |row|
            @row = row
            # Rails.logger.info "#{print}, #{online}, https://doi.org/#{doi}, #{date}, #{title}"
          end
        rescue StandardError => e
          Rails.logger.error "LibPtgBox::Unmarshaller::Kbart.initialize(#{@line}) error #{e}"
          @row = ["UNTITLED", "0000000000000", "0000000000000", "1970-01-01", 5, 6, 7, 8, 9, 10, 11, "10.3998/mpub.00000000"]
        end
      end

      def doi
        @doi ||= @row[11]
      end

      def print
        @print ||= @row[1]
      end

      def online
        @online || @row[2]
      end

      def date
        @date ||= @row[3]
      end

      def title
        @title ||= @row[0]
      end

      private

        def encode_line(line)
          # content_encoding = line.encoding
          # content_valid_encoding = line.valid_encoding?
          # Rails.logger.info "<#{content_valid_encoding}, #{content_encoding}>"
          line.force_encoding('UTF-8').encode('UTF-8')
        end
    end
  end
end
