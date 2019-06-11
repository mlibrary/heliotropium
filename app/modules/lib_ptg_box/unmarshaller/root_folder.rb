# frozen_string_literal: true

module LibPtgBox
  module Unmarshaller
    class RootFolder
      class << self
        def sub_folders
          Box::Service.new.folder(BOX_LIB_PTG_BOX_PATH).folders.map { |folder| SubFolder.new(folder) }
        end
      end
    end
  end
end
