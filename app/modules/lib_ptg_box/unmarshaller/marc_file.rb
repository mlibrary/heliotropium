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
              msg = "LibPtgBox::Unmarshaller::MarcFile(#{name})#marcs(#{entry}) #{e}"
              Rails.logger.error msg
              NotifierMailer.administrators("StandardError", msg).deliver_now
            end
          end
          marc_entries
        end
      end

      private

        def reader_entries
          reader = MARC::Reader.new(string_io_content)
          reader.entries
        end

        def string_io_content
          StringIO.new(encode_content)
        end

        def encode_content
          utf_8_content = content.force_encoding('UTF-8')
          _utf_8_content_encoding = utf_8_content.encoding
          _utf_8_content_valid_encoding = utf_8_content.valid_encoding?

          utf_content = utf_8_content

          return utf_content.encode('UTF-8') if utf_content.valid_encoding?

          msg = "LibPtgBox::Unmarshaller::MarcFile(#{name})#marcs invalid UTF-8 encoding!!!"
          Rails.logger.error msg
          NotifierMailer.administrators("Invalid UTF-8 encoding!!!", msg).deliver_now

          utf_content.encode('UTF-8', 'binary', invalid: :replace, undef: :replace, replace: '')
        end
    end
  end
end
