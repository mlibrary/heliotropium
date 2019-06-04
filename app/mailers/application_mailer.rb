# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  default from: Settings.mailers.from.administrator
  layout 'mailer'
end
