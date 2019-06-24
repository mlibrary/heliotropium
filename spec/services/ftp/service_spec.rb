# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Ftp::Service do
  subject(:service) { described_class.new(host, user, password) }

  let(:host) { instance_double(String, 'host') }
  let(:user) { instance_double(String, 'user') }
  let(:password) { instance_double(String, 'password') }

  it { expect(service.host).to be host }
  it { expect(service.user).to be user }
  it { expect(service.password).to be password }
end
