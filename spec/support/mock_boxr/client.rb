# frozen_string_literal: true

require 'rails_helper'

module MockBoxr
  class Client
    def file_from_path(path)
      File.new(path)
    end

    def folder_from_path(path)
      Folder.new(path)
    end

    def folder_items(folder, _options)
      folder.items
    end

    def download_file(_file)
      'content'
    end

    def upload_file(_path, _folder)
      nil
    end
  end
end
