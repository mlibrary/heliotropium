# frozen_string_literal: true

module Ftp
  class Folder
    def self.null_folder
      NullFolder.new
    end

    def initialize(service, pathname, facts)
      @service = service
      @pathname = pathname
      @facts = facts
    end

    def name
      ::File.basename(@pathname)
    end

    def folders # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
      rvalue = []
      Net::FTP.open(@service.host, username: @service.user, password: @service.password, ssl: true) do |ftp|
        @pathname.split(::File::SEPARATOR).each do |dirname|
          ftp.chdir(dirname)
        end
        ftp.mlsd.each do |entry|
          next if /^\./.match?(entry.pathname)
          next if /file/i.match?(entry.facts['type'])

          rvalue << Ftp::Folder.new(@service, ::File.join(@pathname, entry.pathname), entry.facts)
        end
      rescue StandardError => e
        Rails.logger.error "Ftp::Folder#folders #{e}"
      end
      rvalue
    end

    def files # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
      rvalue = []
      Net::FTP.open(@service.host, username: @service.user, password: @service.password, ssl: true) do |ftp|
        @pathname.split(::File::SEPARATOR).each do |dirname|
          ftp.chdir(dirname)
        end
        ftp.mlsd.each do |entry|
          next unless /file/i.match?(entry.facts['type'])

          rvalue << Ftp::File.new(@service, ::File.join(@pathname, entry.pathname), entry.facts)
        end
      rescue StandardError => e
        Rails.logger.error "Ftp::Folder#files #{e}"
      end
      rvalue
    end

    def delete(filename) # rubocop:disable Metrics/MethodLength
      rvalue = false
      Net::FTP.open(@service.host, username: @service.user, password: @service.password, ssl: true) do |ftp|
        @pathname.split(::File::SEPARATOR).each do |dirname|
          ftp.chdir(dirname)
        end
        ftp.delete(::File.basename(filename))
        rvalue = true
      rescue StandardError => e
        Rails.logger.error "Ftp::Folder#delete(#{filename}) #{e}"
      end
      rvalue
    end

    def upload(filename) # rubocop:disable Metrics/MethodLength
      rvalue = false
      Net::FTP.open(@service.host, username: @service.user, password: @service.password, ssl: true) do |ftp|
        @pathname.split(::File::SEPARATOR).each do |dirname|
          ftp.chdir(dirname)
        end
        ::File.open(filename) do |file|
          ftp.putbinaryfile(file, ::File.basename(filename))
        end
        rvalue = true
      rescue StandardError => e
        Rails.logger.error "Ftp::Folder#upload(#{filename}) #{e}"
      end
      rvalue
    end
  end

  class NullFolder < Folder
    def initialize
      super(nil, nil, {})
    end

    def name
      'NullFolder'
    end

    def folders
      []
    end

    def files
      []
    end

    def upload(filename)
      Rails.logger.error "Ftp::NullFolder#upload(#{filename})"
      false
    end
  end
end
