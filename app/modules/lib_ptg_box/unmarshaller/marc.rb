# frozen_string_literal: true

module LibPtgBox
  module Unmarshaller
    class Marc
      def initialize(entry)
        @entry = entry
      end

      def doi # rubocop:disable Metrics/MethodLength
        @doi ||= begin
          @entry.fields.each do |field|
            next unless /^024$/i.match?(field.tag)
            next unless /^7$/i.match?(field.indicator1)

            field.subfields.each do |subfield|
              next unless /^a$/i.match?(subfield.code)

              return subfield.value
            end
          end
          "10.3998/mpub.00000000"
        end
      end

      def to_marc
        content = @entry.to_marc.to_s

        _utf_8_content = content.force_encoding('UTF-8')
        _utf_8_content_encoding = _utf_8_content.encoding
        _utf_8_content_valid_encoding = _utf_8_content.valid_encoding?

        utf_content = _utf_8_content

        return utf_content.encode('UTF-8') if utf_content.valid_encoding?

        Rails.logger.error("LibPtgBox::Unmarshaller::Marc(#{doi})#to_marc invalid UTF-8 encoding!!!")

        utf_content.encode('UTF-8', 'binary', invalid: :replace, undef: :replace, replace: '')
      end

      def to_xml
        content = @entry.to_xml.to_s

        _utf_8_content = content.force_encoding('UTF-8')
        _utf_8_content_encoding = _utf_8_content.encoding
        _utf_8_content_valid_encoding = _utf_8_content.valid_encoding?

        utf_content = _utf_8_content

        return utf_content.encode('UTF-8') if utf_content.valid_encoding?

        Rails.logger.error("LibPtgBox::Unmarshaller::Marc(#{doi})#to_xml invalid UTF-8 encoding!!!")

        utf_content.encode('UTF-8', 'binary', invalid: :replace, undef: :replace, replace: '')
      end
    end
  end
end
