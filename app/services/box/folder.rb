# frozen_string_literal: true

require "boxr"

module Box
  class Folder
    attr_reader :folder, :etag, :id, :type, :name

    def self.null_folder
      NullFolder.new
    end

    def initialize(folder)
      @folder = folder
      @etag = folder[:etag]
      @id = folder[:id]
      @name = folder[:name]
      @type = folder[:type]
    end

    def folders
      client.folder_items(@folder, fields: %i[id name]).folders.map { |item| Folder.new(item) }
    rescue StandardError => e
      Rails.logger.error("Box::Folder.folders raised #{e}")
      []
    end

    def files
      client.folder_items(@folder, fields: %i[id name]).files.map { |item| File.new(item) }
    rescue StandardError => e
      Rails.logger.error("Box::Folder.files raised #{e}")
      []
    end

    def upload(filepath)
      client.upload_file(filepath, @folder)
      true
    rescue StandardError => e
      Rails.logger.error("Box::Folder.upload(#{filepath}) raised #{e}")
      false
    end

    private

      def client
        @client ||= Boxr::Client.new # uses ENV['BOX_DEVELOPER_TOKEN']
      end
  end

  class NullFolder < Folder
    def initialize
      boxr_mash = BoxrMash.new
      boxr_mash[:etag] = 0
      boxr_mash[:id] = 0
      boxr_mash[:name] = 'NullFolder'
      boxr_mash[:type] = 'folder'
      super(boxr_mash)
    end

    def folders
      []
    end

    def files
      []
    end

    def upload(filepath)
      Rails.logger.error("Box::NullFolder.upload(#{filepath})")
      false
    end
  end
end
