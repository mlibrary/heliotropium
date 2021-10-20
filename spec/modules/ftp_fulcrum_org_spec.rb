# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FtpFulcrumOrg do
  it '#chdir_ftp_fulcrum_org_dir' do
    described_class.chdir_ftp_fulcrum_org_dir
    expect(Dir.pwd).to eq(Rails.root.join('tmp', 'ftp_fulcrum_org').to_s)
  end
end
