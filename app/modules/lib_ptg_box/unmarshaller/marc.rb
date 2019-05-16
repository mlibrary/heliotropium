# frozen_string_literal: true

module LibPtgBox
  module Unmarshaller
    class Marc
      def initialize(entry)
        @entry = entry
      end

      def doi
        @doi ||= begin
          @entry.fields.each do |field|
            next unless /^024$/i.match?(field.tag)
            next unless /^7$/i.match?(field.indicator1)

            field.subfields.each do |subfield|
              next unless /^a$/i.match?(subfield.code)

              return subfield.value
            end
          end
        end
      end
    end
  end
end
