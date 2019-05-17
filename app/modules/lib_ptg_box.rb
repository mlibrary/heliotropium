# frozen_string_literal: true

require_relative 'lib_ptg_box/marshaller'
require_relative 'lib_ptg_box/unmarshaller'

require_relative 'lib_ptg_box/work'
require_relative 'lib_ptg_box/product'
require_relative 'lib_ptg_box/product_family'
require_relative 'lib_ptg_box/lib_ptg_box'

module LibPtgBox
  BOX_LIB_PTG_BOX_PATH = '/Library PTG Box'
  TMP_LIB_PTG_BOX_PATH = Rails.root.join('tmp', 'lib_ptg_box')
  TMP_DOWNLOAD_PATH = Rails.root.join('tmp', 'lib_ptg_box', 'download')
  TMP_UPLOAD_PATH = Rails.root.join('tmp', 'lib_ptg_box', 'upload')

  class << self
    def test # rubocop:disable Metrics/AbcSize
      LibPtgBox.new.product_families.each do |product_family|
        puts product_family.name
        product_family.products.each do |product|
          puts "--> " + product.name + " " + product.yyyy + '-' + product.mm + '-' + product.dd
          product.works.each do |work|
            puts "----> #{work.doi}" unless work.marc?
          end
        end
      end
    end

    def download # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
      FileUtils.rm_rf(TMP_LIB_PTG_BOX_PATH) if Dir.exist?(TMP_LIB_PTG_BOX_PATH)
      Dir.mkdir(TMP_LIB_PTG_BOX_PATH)
      Dir.mkdir(TMP_DOWNLOAD_PATH)
      Dir.chdir(TMP_DOWNLOAD_PATH) do
        Box::Service.new.folder(BOX_LIB_PTG_BOX_PATH).folders.each do |product_family_folder|
          Dir.mkdir(product_family_folder.name)
          Dir.chdir(product_family_folder.name) do
            product_family_folder.folders.each do |folder|
              Dir.mkdir(folder.name)
              Dir.chdir(folder.name) do
                folder.files.each do |file|
                  # FileUtils.touch(file.name)
                  File.open(file.name, "wb") do |f|
                    f.write(file.content)
                    f.close
                  end
                end
              end
            end
          end
        end
      end
      FileUtils.cp_r(TMP_DOWNLOAD_PATH, TMP_UPLOAD_PATH)
    end

    def upload; end
  end
end
