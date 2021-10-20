# frozen_string_literal: true

require "rails_helper"

RSpec.describe NotifierMailer, type: :mailer do
  describe '#administrators' do
    let(:mail) { described_class.administrators(title, text).deliver }
    let(:title) { 'Subject' }
    let(:text) { 'Message Text' }

    it 'is expected' do
      expect(mail.from).to eq([Settings.mailers.no_reply])
      expect(mail.to).to eq(Settings.mailers.administrators)
      expect(mail.subject).to match(title)
      expect(mail.body.encoded).to match(text)
    end
  end

  describe '#marc_file_updates' do
    let(:mail) { described_class.marc_file_updates(publisher, text).deliver }
    let(:publisher) { Settings.ftp_fulcrum_org.publishers.first }
    let(:text) { 'MARC Updates' }

    it 'is expected' do
      expect(mail.from).to eq(publisher.mailers.marc_file_updates.from)
      expect(mail.to).to eq(publisher.mailers.marc_file_updates.to)
      expect(mail.bcc).to eq(publisher.mailers.marc_file_updates.bcc)
      expect(mail.subject).to eq('TESTING MARC file updates')
      expect(mail.body.encoded).to match(text)
    end
  end

  describe '#encoding_error' do
    let(:mail) { described_class.encoding_error(publisher, text).deliver }
    let(:publisher) { Settings.ftp_fulcrum_org.publishers.first }
    let(:text) { 'Encoding Error' }

    it 'is expected' do
      expect(mail.from).to eq(publisher.mailers.encoding_error.from)
      expect(mail.to).to eq(publisher.mailers.encoding_error.to)
      expect(mail.subject).to eq('TESTING MARC record encoding errors')
      expect(mail.body.encoded).to match(text)
    end
  end

  describe '#missing_record' do
    let(:mail) { described_class.missing_record(publisher, text).deliver }
    let(:publisher) { Settings.ftp_fulcrum_org.publishers.first }
    let(:text) { 'Missing Record' }

    it 'is expected' do
      expect(mail.from).to eq(publisher.mailers.missing_record.from)
      expect(mail.to).to eq(publisher.mailers.missing_record.to)
      expect(mail.subject).to eq('TESTING missing MARC records')
      expect(mail.body.encoded).to match(text)
    end
  end
end
