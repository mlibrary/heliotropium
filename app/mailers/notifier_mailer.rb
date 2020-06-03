# frozen_string_literal: true

class NotifierMailer < ApplicationMailer
  def administrators(subject, text)
    @text = text
    mail(to: Settings.mailers.administrators,
         subject: subject)
  end

  def marc_file_updates(collection, text)
    @collection = collection
    @text = text
    mail(to: collection.mailers.marc_file_updates.to,
         from: collection.mailers.marc_file_updates.from,
         bcc: collection.mailers.marc_file_updates.bcc,
         subject: collection.mailers.marc_file_updates.subject)
  end

  def encoding_error(collection, text)
    @collection = collection
    @text = text
    mail(to: collection.mailers.encoding_error.to,
         from: collection.mailers.encoding_error.from,
         bcc: collection.mailers.encoding_error.bcc,
         subject: collection.mailers.encoding_error.subject)
  end

  def missing_record(collection, text)
    @collection = collection
    @text = text
    mail(to: collection.mailers.missing_record.to,
         from: collection.mailers.missing_record.from,
         bcc: collection.mailers.missing_record.bcc,
         subject: collection.mailers.missing_record.subject)
  end
end
