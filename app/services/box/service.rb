# frozen_string_literal: true

require "boxr"

module Box
  class Service
    def root_folder
      Folder.new(id: Boxr::ROOT, name: '')
    end

    def folder(path)
      Folder.new(client.folder_from_path(path))
    end

    def file(path)
      File.new(client.file_from_path(path))
    end

    private

      def client
        @client ||= Boxr::Client.new # uses ENV['BOX_DEVELOPER_TOKEN']
      end
  end
end
