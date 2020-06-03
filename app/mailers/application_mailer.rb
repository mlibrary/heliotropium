# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  default from: Settings.mailers.no_reply
  layout 'mailer'
end
