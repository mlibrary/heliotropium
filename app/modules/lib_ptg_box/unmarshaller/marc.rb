# frozen_string_literal: true

module LibPtgBox
  module Unmarshaller
    class Marc
      attr_reader :entry

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

      def to_mrc
        @entry.to_marc
      end

      def to_xml
        @entry.to_xml
      end
    end
  end
end
