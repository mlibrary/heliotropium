# frozen_string_literal: true

module Marc
  class Marc
    def to_mrc
      "mrc\n"
    end

    def to_xml
      "xml\n"
    end

    def in_file?(_filename)
      false
    end
  end
end
