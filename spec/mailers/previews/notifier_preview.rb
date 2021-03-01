# frozen_string_literal: true

# Preview all emails at http://localhost:3000/rails/mailers/notifier
class NotifierPreview < ActionMailer::Preview
  def administrators
    NotifierMailer.administrators("Subject", "Hello World!!!")
  end

  def amherst_press_encoding_error
    NotifierMailer.encoding_error(collection('amherst'), "Hello World!!!")
  end

  def amherst_press_missing_record
    NotifierMailer.missing_record(collection('amherst'), "Hello World!!!")
  end

  def amherst_press_marc_file_updates
    NotifierMailer.marc_file_updates(collection('amherst'), "Hello World!!!")
  end

  def bar_encoding_error
    NotifierMailer.encoding_error(collection('bar'), "Hello World!!!")
  end

  def bar_missing_record
    NotifierMailer.missing_record(collection('bar'), "Hello World!!!")
  end

  def bar_marc_file_updates
    NotifierMailer.marc_file_updates(collection('bar'), "Hello World!!!")
  end

  def lever_press_encoding_error
    NotifierMailer.encoding_error(collection('leverpress'), "Hello World!!!")
  end

  def lever_press_missing_record
    NotifierMailer.missing_record(collection('leverpress'), "Hello World!!!")
  end

  def lever_press_marc_file_updates
    NotifierMailer.marc_file_updates(collection('leverpress'), "Hello World!!!")
  end

  def umpebc_encoding_error
    NotifierMailer.encoding_error(collection('umpebc'), "Hello World!!!")
  end

  def umpebc_missing_record
    NotifierMailer.missing_record(collection('umpebc'), "Hello World!!!")
  end

  def umpebc_marc_file_updates
    NotifierMailer.marc_file_updates(collection('umpebc'), "Hello World!!!")
  end

  private

    def collection(key)
      Settings.lib_ptg_box.collections.each do |collection|
        next unless collection.key == key

        return collection
      end
    end
end
