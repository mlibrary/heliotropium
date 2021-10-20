# frozen_string_literal: true

class NotifierMailer < ApplicationMailer
  def administrators(subject, text)
    @text = text
    mail(to: Settings.mailers.administrators,
         subject: subject)
  end

  def marc_file_updates(publisher, text)
    @publisher = publisher
    @text = text
    mail(to: publisher.mailers.marc_file_updates.to,
         from: publisher.mailers.marc_file_updates.from,
         bcc: publisher.mailers.marc_file_updates.bcc,
         subject: publisher.mailers.marc_file_updates.subject)
  end

  def encoding_error(publisher, text)
    @publisher = publisher
    @text = text
    mail(to: publisher.mailers.encoding_error.to,
         from: publisher.mailers.encoding_error.from,
         bcc: publisher.mailers.encoding_error.bcc,
         subject: publisher.mailers.encoding_error.subject)
  end

  def missing_record(publisher, text)
    @publisher = publisher
    @text = text
    mail(to: publisher.mailers.missing_record.to,
         from: publisher.mailers.missing_record.from,
         bcc: publisher.mailers.missing_record.bcc,
         subject: publisher.mailers.missing_record.subject)
  end
end
