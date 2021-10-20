# frozen_string_literal: true

module FtpFulcrumOrg
  class Catalog
    def initialize(publisher, sftp, pathname)
      @publisher = publisher
      @sftp = sftp
      @pathname = pathname
    end

    def marc_files
      @marc_files ||= begin
        files = []
        @sftp.dir.entries(@pathname).each do |entry|
          next unless /(mrc|xml)/i.match?(File.extname(entry.name))

          files << MarcFile.new(@sftp, File.join(@pathname, entry.name))
        end
        files
      end
    end

    def marc(doi)
      marcs.each do |marc|
        next unless /#{doi}/i.match?(marc.doi)

        return marc
      end
      nil
    end

    def marcs # rubocop:disable  Metrics/MethodLength
      @marcs ||= begin
        marcs = []
        ::MarcRecord.where(folder: @publisher.key).each do |db_marc_record|
          next unless db_marc_record.parsed

          begin
            marc = MARC::Reader.decode(db_marc_record.mrc, external_encoding: "UTF-8", validate_encoding: true)
            marcs << Marc.new(marc)
          rescue Encoding::InvalidByteSequenceError => e
            msg = "FtpFulcrumOrg::Catalog#marcs(id #{db_marc_record.id}, doi #{db_marc_record.doi}) #{e}"
            Rails.logger.error msg
            NotifierMailer.administrators("StandardError", msg).deliver_now
          end
        end
        marcs
      end
    end
  end
end
