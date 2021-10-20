# frozen_string_literal: true

module FtpFulcrumOrg
  class Collection
    attr_reader :publisher
    attr_reader :name
    attr_reader :updated

    def initialize(publisher, sftp, pathname)
      @publisher = publisher
      @sftp = sftp
      @pathname = pathname
      match = /(^.+)_(\d{4}-\d{2}-\d{2})\.(.+$)/.match(File.basename(@pathname))
      @name = match[1]
      @updated = Date.parse(match[2])
      @ext = match[3]
    end

    def works
      @works ||= begin
        kbart_file = KbartFile.new(@sftp, @pathname)
        kbart_file.kbarts.map { |kbart| Work.new(self, kbart) }
      end
    end
  end
end
