# frozen_string_literal: true

module Marc
  class Marc
    def initialize
    end

    def to_mrc
      "mrc\n"
    end

    def to_xml
      "xml\n"
    end

    def in_file?(filename)
      false
    end
  end
end
