# frozen_string_literal: true

require 'rails_helper'

module MockBoxr
  class Item < Hash
    attr_reader :etag, :id, :name, :type

    def initialize(name, type)
      self[:etag] = 'etag'
      self[:id] = 'id'
      self[:name] = name
      self[:type] = type
      @etag = self[:etag]
      @id = self[:id]
      @name = self[:name]
      @type = self[:type]
    end
  end
end
