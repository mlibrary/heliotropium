# frozen_string_literal: true

require "rails_helper"

RSpec.describe NotifierMailer, type: :mailer do
  describe '#administrators' do
    let(:mail) { described_class.administrators(text).deliver }

    let(:text) { "Message text." }

    it 'is expected' do # rubocop:disable RSpec/MultipleExpectations
      expect(mail.from).to eq(Settings.mailers.from.no_reply)
      expect(mail.to).to eq(Settings.mailers.to.administrators)
      expect(mail.subject).to eq("Administrators")
      expect(mail.body.to_s).to match(text)
    end
  end
end
