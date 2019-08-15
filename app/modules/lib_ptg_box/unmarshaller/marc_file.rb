# frozen_string_literal: true

module LibPtgBox
  module Unmarshaller
    class MarcFile < SimpleDelegator
      def marcs # rubocop:disable Metrics/MethodLength
        @marcs ||= begin
          marc_entries = []
          begin
            reader_entries.each do |entry|
              marc_entries << Unmarshaller::Marc.new(entry)
            rescue StandardError => e
              Rails.logger.error "LibPtgBox::Unmarshaller::MarcFile(#{name})#marcs(#{entry}) #{e}"
            end
          rescue StandardError => e
            Rails.logger.error "LibPtgBox::Unmarshaller::MarcFile(#{name})#marcs #{e}"
          end
          marc_entries
        end
      end

      private

        def encode_content
          _utf_8_content = content.force_encoding('UTF-8')
          _utf_8_content_encoding = _utf_8_content.encoding
          _utf_8_content_valid_encoding = _utf_8_content.valid_encoding?

          utf_content = _utf_8_content

          return utf_content.encode('UTF-8') if utf_content.valid_encoding?

          Rails.logger.error("LibPtgBox::Unmarshaller::MarcFile(#{name})#marcs invalid UTF-8 encoding!!!")

          utf_content.encode('UTF-8', 'binary', invalid: :replace, undef: :replace, replace: '')
        end

        def string_io_content
          StringIO.new(encode_content)
        end

        def reader_entries
          reader = MARC::Reader.new(string_io_content)
          reader.entries
        end
    end
  end
end
