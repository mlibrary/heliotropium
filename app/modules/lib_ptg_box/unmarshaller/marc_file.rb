# frozen_string_literal: true

module LibPtgBox
  module Unmarshaller
    class MarcFile < SimpleDelegator
      def marcs # rubocop:disable Metrics/MethodLength
        @marcs ||= begin
          # reader_entries.map { |entry| Unmarshaller::Marc.new(entry) }
          marc_entries = []
          begin
            reader_entries.each do |entry|
              marc_entries << Unmarshaller::Marc.new(entry)
            rescue StandardError => e
              Rails.logger.error e.to_s
            end
          rescue StandardError => e
            Rails.logger.error e.to_s
          end
          marc_entries
        end
      end

      private

        def encode_content
          # content.force_encoding('UTF-8').encode('UTF-8')

          # utf_16_content = content.force_encoding('UTF-16')
          # utf_16_content_encoding = utf_16_content.encoding
          # utf_16_content_valid_encoding = utf_16_content.valid_encoding?
          #
          # utf_16be_content = content.force_encoding('UTF-16BE')
          # utf_16be_content_encoding = utf_16be_content.encoding
          # utf_16be_content_valid_encoding = utf_16be_content.valid_encoding?
          #
          # utf_16le_content = content.force_encoding('UTF-16LE')
          # utf_16le_content_encoding = utf_16le_content.encoding
          # utf_16le_content_valid_encoding = utf_16le_content.valid_encoding?
          #
          # utf_32_content = content.force_encoding('UTF-32')
          # utf_32_content_encoding = utf_32_content.encoding
          # utf_32_content_valid_encoding = utf_32_content.valid_encoding?

          utf_8_content = content.force_encoding('UTF-8')
          _utf_8_content_encoding = utf_8_content.encoding
          _utf_8_content_valid_encoding = utf_8_content.valid_encoding?

          utf_content = utf_8_content
          return utf_content.encode('UTF-8') if utf_content.valid_encoding?

          utf_content.encode('UTF-8', 'binary', invalid: :replace, undef: :replace, replace: '')
        end

        def string_io_content
          StringIO.new(encode_content)
        end

        def reader_entries
          reader = MARC::XMLReader.new(string_io_content)
          reader.entries
        end
    end
  end
end
