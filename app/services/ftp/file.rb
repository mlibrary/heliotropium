# frozen_string_literal: true

module Ftp
  class File
    def self.null_file
      NullFile.new
    end

    def initialize(service, pathname, facts)
      @service = service
      @pathname = pathname
      @facts = facts
    end

    def name
      ::File.basename(@pathname)
    end

    def extension
      ::File.extname(@pathname)
    end

    def updated
      Date.parse(@facts['modify'].to_s)
    end

    def content
      Net::FTP.open(@service.host, username: @service.user, password: @service.password, ssl: true) do |ftp|
        ::File.dirname(@pathname).split(::File::SEPARATOR).each do |dirname|
          ftp.chdir(dirname)
        end
        ftp.getbinaryfile(name, nil)
      end
    rescue StandardError => e
      Rails.logger.error "Ftp::File#content(#{@pathname}) #{e}"
      ''
    end
  end

  class NullFile < File
    def initialize
      super(nil, nil, {})
    end

    def name
      ''
    end

    def content
      ''
    end
  end
end
