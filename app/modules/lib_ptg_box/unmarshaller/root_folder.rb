# frozen_string_literal: true

module LibPtgBox
  module Unmarshaller
    class RootFolder
      class << self
        def sub_folders
          ftp_service = Ftp::Service.new(Settings.lib_ptg_box.ftp, Settings.lib_ptg_box.user, Settings.lib_ptg_box.password)
          root_folder = Ftp::Folder.new(ftp_service, Settings.lib_ptg_box.root)
          root_folder.folders.map { |folder| SubFolder.new(folder) }
        end
      end
    end
  end
end
