# frozen_string_literal: true

module LibPtgBox
  class LibPtgBox
    def product_families
      @product_families ||= Unmarshaller::RootFolder.family_folders.map { |family_folder| ProductFamily.new(family_folder) }
    end
  end
end
