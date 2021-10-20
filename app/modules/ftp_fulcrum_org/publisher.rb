# frozen_string_literal: true

module FtpFulcrumOrg
  class Publisher
    attr_reader :key
    attr_reader :name

    def initialize(sftp, publisher)
      @sftp = sftp
      @publisher = publisher
      @key = publisher.key
      @name = publisher.name
      @mailers = publisher.mailers
    end

    def collections # rubocop:disable Metrics/AbcSize
      @collections ||= begin
        pathname = File.join(Settings.ftp_fulcrum_org.home, Settings.ftp_fulcrum_org.pub, @publisher.pub, Settings.ftp_fulcrum_org.kbart)
        entries = []
        @sftp.dir.entries(pathname).each do |entry|
          next unless /csv/i.match?(File.extname(entry.name))

          entries << entry
        end
        entries.sort_by(&:name).reverse.map { |e| Collection.new(self, @sftp, File.join(pathname, e.name)) }
      end
    end

    def upload_marc_file(filename)
      pathname = File.join(Settings.ftp_fulcrum_org.home, Settings.ftp_fulcrum_org.pub, @publisher.pub, Settings.ftp_fulcrum_org.marc)
      @sftp.upload!(filename, File.join(pathname, filename))
    end

    # def marc(doi)
    #   marcs.each do |marc|
    #     next unless /#{doi}/i.match?(marc.doi)
    #
    #     return marc
    #   end
    #   nil
    # end

    # def marcs
    #   @marcs ||= begin
    #                complete_marc_file = nil
    #                @sub_folder.marc_folder.marc_files.each do |marc_file|
    #                  next unless /complete\.mrc/i.match?(marc_file.name)
    #
    #                  complete_marc_file = marc_file
    #                  break
    #                end
    #                complete_marc_file.marcs
    #              end
    # end

    def catalog
      @catalog ||= Catalog.new(self, @sftp, File.join(Settings.ftp_fulcrum_org.home, Settings.ftp_fulcrum_org.cat, @publisher.cat))
    end
  end
end
