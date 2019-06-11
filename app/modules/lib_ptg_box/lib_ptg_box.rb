# frozen_string_literal: true

module LibPtgBox
  class LibPtgBox
    def collections
      @collections ||= Unmarshaller::RootFolder.sub_folders.map { |sub_folder| Collection.new(sub_folder) }
    end
  end
end
