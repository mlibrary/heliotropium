# frozen_string_literal: true

# Preview all emails at http://localhost:3000/rails/mailers/notifier
class NotifierPreview < ActionMailer::Preview
  def administrators
    NotifierMailer.administrators("Hello World!!!")
  end

  def mpub_cataloging_encoding_error
    NotifierMailer.mpub_cataloging_encoding_error("Hello World!!!")
  end

  def mpub_cataloging_missing_record
    NotifierMailer.mpub_cataloging_missing_record("Hello World!!!")
  end
end
