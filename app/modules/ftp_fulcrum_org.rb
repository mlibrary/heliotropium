# frozen_string_literal: true

require_relative 'ftp_fulcrum_org/marc'
require_relative 'ftp_fulcrum_org/marc_file'
require_relative 'ftp_fulcrum_org/catalog'
require_relative 'ftp_fulcrum_org/kbart'
require_relative 'ftp_fulcrum_org/kbart_file'
require_relative 'ftp_fulcrum_org/work'
require_relative 'ftp_fulcrum_org/collection'
require_relative 'ftp_fulcrum_org/publisher'
require_relative 'ftp_fulcrum_org/ftp_fulcrum_org'

module FtpFulcrumOrg
  def self.chdir_ftp_fulcrum_org_dir
    tmp_dir = Rails.root.join('tmp')
    Dir.mkdir(tmp_dir) unless Dir.exist?(tmp_dir)
    Dir.chdir(tmp_dir)
    Dir.mkdir('ftp_fulcrum_org') unless Dir.exist?('ftp_fulcrum_org')
    Dir.chdir('ftp_fulcrum_org')
  end
end
