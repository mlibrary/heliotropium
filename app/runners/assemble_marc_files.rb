# frozen_string_literal: true

class AssembleMarcFiles
  def run
    modified_product = nil
    umpebc_collection.products.each do |product|
      next unless product.modified_today?

      modified_product = product
    end
    modified_product
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
                                   raise 'umpebc product family not found' unless umpebc_family

                                   umpebc_family
                                 end
    end
end
