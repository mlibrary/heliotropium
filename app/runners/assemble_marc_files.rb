# frozen_string_literal: true

class AssembleMarcFiles
  def run
    modified_product = nil
    umpebc_product_family.products.each do |product|
      next unless product.modified_today?

      modified_product = product
    end
    modified_product
  end

  private

  def umpebc_product_family # rubocop:disable Metrics/MethodLength
    @umpebc_product_family ||= begin
                                 product_families = LibPtgBox::LibPtgBox.new.product_families
                                 umpebc_family = nil
                                 product_families.each do |family|
                                   next unless /umpebc/i.match?(family.name)

                                   umpebc_family = family
                                   break
                                 end
                                 raise 'umpebc product family not found' unless umpebc_family

                                 umpebc_family
                               end
  end
end
