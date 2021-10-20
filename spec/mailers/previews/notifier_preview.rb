# frozen_string_literal: true

# Preview all emails at http://localhost:3000/rails/mailers/notifier
class NotifierPreview < ActionMailer::Preview
  def administrators
    NotifierMailer.administrators("Subject", "Hello World!!!")
  end

  def amherst_press_encoding_error
    NotifierMailer.encoding_error(publisher('amherst'), "Hello World!!!")
  end

  def amherst_press_missing_record
    NotifierMailer.missing_record(publisher('amherst'), "Hello World!!!")
  end

  def amherst_press_marc_file_updates
    NotifierMailer.marc_file_updates(publisher('amherst'), "Hello World!!!")
  end

  def bar_encoding_error
    NotifierMailer.encoding_error(publisher('bar'), "Hello World!!!")
  end

  def bar_missing_record
    NotifierMailer.missing_record(publisher('bar'), "Hello World!!!")
  end

  def bar_marc_file_updates
    NotifierMailer.marc_file_updates(publisher('bar'), "Hello World!!!")
  end

  def lever_press_encoding_error
    NotifierMailer.encoding_error(publisher('leverpress'), "Hello World!!!")
  end

  def lever_press_missing_record
    NotifierMailer.missing_record(publisher('leverpress'), "Hello World!!!")
  end

  def lever_press_marc_file_updates
    NotifierMailer.marc_file_updates(publisher('leverpress'), "Hello World!!!")
  end

  def umpebc_encoding_error
    NotifierMailer.encoding_error(publisher('umpebc'), "Hello World!!!")
  end

  def umpebc_missing_record
    NotifierMailer.missing_record(publisher('umpebc'), "Hello World!!!")
  end

  def umpebc_marc_file_updates
    NotifierMailer.marc_file_updates(publisher('umpebc'), "Hello World!!!")
  end

  private

    def publisher(key)
      Settings.ftp_fulcrum_org.publishers.each do |publisher|
        next unless publisher.key == key

        return publisher
      end
    end
end
