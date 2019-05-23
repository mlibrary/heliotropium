# frozen_string_literal: true

require 'rails_helper'

module MockBoxr
  class File < Item
    def initialize(path)
      super(::File.basename(path), 'file')
      @path = path
    end

    def content
      'content'
    end
  end
end
