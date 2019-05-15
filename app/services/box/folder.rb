# frozen_string_literal: true

require "boxr"

module Box
  class Folder
    def initialize(folder)
      @folder = folder
    end

    def folders
      client.folder_items(@folder, fields: %i[id name]).folders.map { |item| Folder.new(item) }
    rescue StandardError => e
      Rails.logger.error("Box::Folder.folders raised #{e}")
    end

    def files
      client.folder_items(@folder, fields: %i[id name]).files.map { |item| File.new(item) }
    rescue StandardError => e
      Rails.logger.error("Box::Folder.files raised #{e}")
    end

    def upload(filepath)
      client.upload_file(filepath, @folder)
    rescue StandardError => e
      Rails.logger.error("Box::Folder.upload(#{filepath}) raised #{e}")
    end

    private

    def client
      @client ||= Boxr::Client.new # uses ENV['BOX_DEVELOPER_TOKEN']
    end
  end
end
