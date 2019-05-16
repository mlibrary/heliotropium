# frozen_string_literal: true

module LibPtgBox
  module Unmarshaller
    class MarcFolder < SimpleDelegator
      def marc_files
        @marc_files ||= files.map { |file| MarcFile.new(file) }
      end
    end
  end
end
