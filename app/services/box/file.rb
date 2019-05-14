# frozen_string_literal: true

require "boxr"

module Box
  class File
    attr_reader :file, :etag, :id, :type, :name

    def initialize(file)
      @file = file
      @etag = file[:etag]
      @id = file[:id]
      @type = file[:type]
      @name = file[:name]
    end

    def content
      client.download_file(@file)
    end

    private

      def client
        @client ||= Boxr::Client.new # uses ENV['BOX_DEVELOPER_TOKEN']
      end
  end
end
