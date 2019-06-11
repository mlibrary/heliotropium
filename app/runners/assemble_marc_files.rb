# frozen_string_literal: true

class AssembleMarcFiles
  def run
    modified_selection = nil
    umpebc_collection.selections.each do |selection|
      next unless selection.modified_today?

      modified_selection = selection
    end
    modified_selection
  end

  private

    def umpebc_collection # rubocop:disable Metrics/MethodLength
      @umpebc_collection ||= begin
                                   collections = LibPtgBox::LibPtgBox.new.collections
                                   umpebc_family = nil
                                   collections.each do |family|
                                     next unless /umpebc/i.match?(family.name)

                                     umpebc_family = family
                                     break
                                   end
                                   raise 'umpebc selection family not found' unless umpebc_family

                                   umpebc_family
                                 end
    end
end
