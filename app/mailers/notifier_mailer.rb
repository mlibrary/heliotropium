# frozen_string_literal: true

class NotifierMailer < ApplicationMailer
  default from: Settings.mailers.from.no_reply

  def administrators(text)
    @text = text
    mail(to: Settings.mailers.to.administrators)
  end
end
