# frozen_string_literal: true

module LibPtgBox
  class LibPtgBox
    def product_families
      @product_families ||= Unmarshaller::RootFolder.sub_folders.map { |sub_folder| ProductFamily.new(sub_folder) }
    end
  end
end
