# frozen_string_literal: true

module LibPtgBox
  module Unmarshaller
    class MarcFile < SimpleDelegator
      def marcs
        @marcs ||= []
      end
    end
  end
end
