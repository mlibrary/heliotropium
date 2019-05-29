# frozen_string_literal: true

FactoryBot.define do
  factory :uuid_identifier do
    uuid { FactoryBot.create(:uuid) }
    identifier { FactoryBot.create(:identifier) }
  end
end
