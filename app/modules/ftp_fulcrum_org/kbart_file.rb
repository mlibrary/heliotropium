# frozen_string_literal: true

module FtpFulcrumOrg
  class KbartFile
    def initialize(sftp, pathname)
      @sftp = sftp
      @pathname = pathname
    end

    def kbarts # rubocop:disable Metrics/MethodLength
      @kbarts ||= begin
        kbarts = []
        file = @sftp.file.open(@pathname)
        line = file.gets # skip header
        line = file.gets if line
        while line
          kbarts << Kbart.new(line) if line.length > 9
          line = file.gets
        end
        file.close
        kbarts
      end
    end
  end
end
