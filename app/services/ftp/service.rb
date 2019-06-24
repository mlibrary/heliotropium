# frozen_string_literal: true

module Ftp
  class Service
    attr_reader :host, :user, :password

    def initialize(host, user, password)
      @host = host
      @user = user
      @password = password
    end
  end
end
