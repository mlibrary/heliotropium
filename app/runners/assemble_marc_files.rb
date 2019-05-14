# frozen_string_literal: true

class AssembleMarcFiles
  BOX_KBART_FOLDER = '/My Box Notes/cronuts/download/kbart'
  BOX_MARC_FOLDER = '/My Box Notes/cronuts/download/marc'
  BOX_CATALOG_FOLDER = '/My Box Notes/cronuts/download/catalog'
  BOX_UPLOAD_FOLDER = '/My Box Notes/cronuts/upload/marc'

  TMP_DIR = Rails.root.join('tmp')
  TMP_ASSEMBLE_MARC_FILES_ROOT = File.join(TMP_DIR, 'assemble_marc_files')

  TMP_DOWNLOAD_DIR = File.join(TMP_ASSEMBLE_MARC_FILES_ROOT, 'download')
  TMP_KBART_DOWNLOAD_DIR = File.join(TMP_DOWNLOAD_DIR, 'kbart')
  TMP_MARC_DOWNLOAD_DIR = File.join(TMP_DOWNLOAD_DIR, 'marc')
  TMP_CATALOGING_DOWNLOAD_DIR = File.join(TMP_DOWNLOAD_DIR, 'cataloging')

  TMP_UPLOAD_DIR = File.join(TMP_ASSEMBLE_MARC_FILES_ROOT, 'upload')
  TMP_KBART_UPLOAD_DIR = File.join(TMP_UPLOAD_DIR, 'kbart')
  TMP_MARC_UPLOAD_DIR = File.join(TMP_UPLOAD_DIR, 'marc')
  TMP_CATALOGING_UPLOAD_DIR = File.join(TMP_UPLOAD_DIR, 'cataloging')

  def run(rebuild = false)
    download
    update(rebuild)
    upload
  end

  def download
    FileUtils.rm_rf(TMP_ASSEMBLE_MARC_FILES_ROOT) if Dir.exist?(TMP_ASSEMBLE_MARC_FILES_ROOT)
    Dir.mkdir(TMP_ASSEMBLE_MARC_FILES_ROOT)
    Dir.mkdir(TMP_DOWNLOAD_DIR)
    Dir.mkdir(TMP_KBART_DOWNLOAD_DIR)
    Dir.chdir(TMP_KBART_DOWNLOAD_DIR) do
      Box::Service.new.folder(BOX_KBART_FOLDER).files.each do |file|
        File.open(file.name, "wb") do |f|
          f.write(file.content)
          f.close
        end
      end
    end
    Dir.mkdir(TMP_MARC_DOWNLOAD_DIR)
    Dir.chdir(TMP_MARC_DOWNLOAD_DIR) do
      Box::Service.new.folder(BOX_MARC_FOLDER).files.each do |file|
        File.open(file.name, "wb") do |f|
          f.write(file.content)
          f.close
        end
      end
    end
    Dir.mkdir(TMP_CATALOGING_DOWNLOAD_DIR)
    Dir.chdir(TMP_CATALOGING_DOWNLOAD_DIR) do
      Box::Service.new.folder(BOX_CATALOG_FOLDER).files.each do |file|
        File.open(file.name, "wb") do |f|
          f.write(file.content)
          f.close
        end
      end
    end
    Dir.mkdir(TMP_UPLOAD_DIR)
    Dir.mkdir(TMP_KBART_UPLOAD_DIR)
    Dir.chdir(TMP_KBART_UPLOAD_DIR) do
      Box::Service.new.folder(BOX_KBART_FOLDER).files.each do |file|
        File.open(file.name, "wb") do |f|
          f.write(file.content)
          f.close
        end
      end
    end
    Dir.mkdir(TMP_MARC_UPLOAD_DIR)
    Dir.chdir(TMP_MARC_UPLOAD_DIR) do
      Box::Service.new.folder(BOX_MARC_FOLDER).files.each do |file|
        File.open(file.name, "wb") do |f|
          f.write(file.content)
          f.close
        end
      end
    end
    Dir.mkdir(TMP_CATALOGING_UPLOAD_DIR)
    Dir.chdir(TMP_CATALOGING_UPLOAD_DIR) do
      Box::Service.new.folder(BOX_CATALOG_FOLDER).files.each do |file|
        File.open(file.name, "wb") do |f|
          f.write(file.content)
          f.close
        end
      end
    end
  end

  def update(rebuild)
    product_names = []
    mm = "%02d" % [Time.now.month]

    Dir.chdir(TMP_KBART_DOWNLOAD_DIR) do
      Dir.foreach('.') do |item|
        next unless File.file?(item)
        product = Kbart::Filename.new(item)
        product_names << product.name
        next unless rebuild || product.modified_today?
        new_mrc_file = File.open(File.join(TMP_MARC_UPLOAD_DIR, "#{product.base}.mrc"), "w")
        new_xml_file = File.open(File.join(TMP_MARC_UPLOAD_DIR, "#{product.base}.xml"), "w")
        if product.year?
          new_mrc_mm_file = File.open(File.join(TMP_MARC_UPLOAD_DIR, "#{product.base}_#{mm}.mrc"), "a")
          new_xml_mm_file = File.open(File.join(TMP_MARC_UPLOAD_DIR, "#{product.base}_#{mm}.xml"), "a")
        end
        catalog = Cataloging::Cataloging.new(product)
        kbart = Kbart::Kbart.new(File.join(TMP_KBART_DOWNLOAD_DIR, item))
        kbart.dois.each do |doi|
          marc = catalog.marc(doi)
          next unless marc
          new_mrc_file << marc.to_mrc
          new_xml_file << marc.to_xml
          if product.year?
            unless marc.in_file?(File.join(TMP_MARC_DOWNLOAD_DIR, "#{product.base}.mrc"))
              if File.exist?(File.join(TMP_MARC_DOWNLOAD_DIR, "#{product.base}_#{mm}.mrc"))
                unless marc.in_file?(File.join(TMP_MARC_DOWNLOAD_DIR, "#{product.base}_#{mm}.mrc"))
                  new_mrc_mm_file << marc.to_mrc
                end
              else
                new_mrc_mm_file << marc.to_mrc
              end
            end
            unless marc.in_file?(File.join(TMP_MARC_DOWNLOAD_DIR, "#{product.base}.xml"))
              if File.exist?(File.join(TMP_MARC_DOWNLOAD_DIR, "#{product.base}_#{mm}.xml"))
                unless marc.in_file?(File.join(TMP_MARC_DOWNLOAD_DIR, "#{product.base}_#{mm}.xml"))
                  new_xml_mm_file << marc.to_xml
                end
              else
                new_xml_mm_file << marc.to_xml
              end
            end
          end
        end
        new_mrc_file.close
        new_xml_file.close
        if product.year?
          new_mrc_mm_file.close
          new_xml_mm_file.close
        end
      end
      Dir.chdir(TMP_MARC_UPLOAD_DIR) do
        product_names.uniq.each do |name|
          complete_mrc_file = File.open(File.join(TMP_MARC_UPLOAD_DIR, "#{name}_Complete.mrc"), "w")
          complete_xml_file = File.open(File.join(TMP_MARC_UPLOAD_DIR, "#{name}_Complete.xml"), "w")
          Dir.foreach('.') do |item|
            next unless File.file?(item)
            product = Marc::Filename.new(item)
            next unless /^#{name}$/i.match?(product.name)
            next if product.open_access?
            next if product.monthly?
            next if product.complete?
            puts product.inspect
            if product.mrc?
              complete_mrc_file.write(File.read(item))
            elsif product.xml?
              complete_xml_file.write(File.read(item))
            end
          end
          complete_mrc_file.close
          complete_xml_file.close
        end
      end
    end
  end

  def upload
    box_upload_folder = Box::Service.new.folder(BOX_UPLOAD_FOLDER)
    Dir.chdir(TMP_MARC_UPLOAD_DIR) do
      Dir.foreach('.') do |item|
        next unless File.file?(item)
        next if File.size?(item) == File.size?(File.join(TMP_MARC_DOWNLOAD_DIR, item)) if File.exist?(File.join(TMP_MARC_DOWNLOAD_DIR, item))
        box_upload_folder.upload(File.join(TMP_MARC_UPLOAD_DIR, item))
      end
    end
  end
end
