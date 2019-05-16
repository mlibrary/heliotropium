# frozen_string_literal: true

require "boxr"

module Box
  class File
    attr_reader :file, :etag, :id, :type, :name

    def self.null_file
      NullFile.new
    end

    def initialize(file)
      @file = file
      @etag = file[:etag]
      @id = file[:id]
      @name = file[:name]
      @type = file[:type]
    end

    def content
      error = nil
      buffer = nil
      3.times do
        next if buffer

        buffer = client.download_file(@file)
      rescue StandardError => e
        error = e
        buffer = nil
      end
      buffer || error
    end

    private

    def client
      @client ||= Boxr::Client.new # uses ENV['BOX_DEVELOPER_TOKEN']
    end
  end

  class NullFile < File
    def initialize
      boxr_mash = BoxrMash.new
      boxr_mash[:etag] = 0
      boxr_mash[:id] = 0
      boxr_mash[:name] = 'NullFile'
      boxr_mash[:type] = 'file'
      super(boxr_mash)
    end

    def content
      ''
    end
  end
end
