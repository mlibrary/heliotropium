# frozen_string_literal: true

# Preview all emails at http://localhost:3000/rails/mailers/notifier
class NotifierPreview < ActionMailer::Preview
  def administrators
    NotifierMailer.administrators("Hello World!!!")
  end
end
