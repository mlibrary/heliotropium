# frozen_string_literal: true

require "rails_helper"

RSpec.describe NotifierMailer, type: :mailer do
  describe '#administrators' do
    let(:mail) { described_class.administrators(text).deliver }
    let(:text) { 'Message Text' }

    it 'is expected' do
      expect(mail.from).to eq(Settings.mailers.from.no_reply)
      expect(mail.to).to eq(Settings.mailers.to.administrators)
      expect(mail.subject).to eq("Administrators")
      expect(mail.body.encoded).to match(text)
    end
  end

  describe '#fulcrum_info_umpebc_marc_updates' do
    let(:mail) { described_class.fulcrum_info_umpebc_marc_updates(text).deliver }
    let(:text) { 'MARC Updates' }

    it 'is expected' do
      expect(mail.from).to eq(Settings.mailers.from.fulcrum_info)
      expect(mail.to).to eq(Settings.mailers.to.fulcrum_info)
      expect(mail.bcc).to eq(Settings.mailers.bcc.ebc_tech_contacts)
      expect(mail.subject).to eq('University of Michigan Press Ebook Collection MARC updates')
      expect(mail.body.encoded).to match(text)
    end
  end

  describe '#mpub_cataloging_encoding_error' do
    let(:mail) { described_class.mpub_cataloging_encoding_error(text).deliver }
    let(:text) { 'Encoding Error' }

    it 'is expected' do
      expect(mail.from).to eq(Settings.mailers.from.fulcrum_dev)
      expect(mail.to).to eq(Settings.mailers.to.mpub_cataloging)
      expect(mail.subject).to eq('bad character encoding in MARC records for Michigan Publishing')
      expect(mail.body.encoded).to match(text)
    end
  end

  describe '#mpub_cataloging_missing_record' do
    let(:mail) { described_class.mpub_cataloging_missing_record(text).deliver }
    let(:text) { 'Missing Record' }

    it 'is expected' do
      expect(mail.from).to eq(Settings.mailers.from.fulcrum_dev)
      expect(mail.to).to eq(Settings.mailers.to.mpub_cataloging)
      expect(mail.subject).to eq('missing MARC records for Michigan Publishing')
      expect(mail.body.encoded).to match(text)
    end
  end
end
