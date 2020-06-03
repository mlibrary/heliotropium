# frozen_string_literal: true

FactoryBot.define do
  factory :marc_file do
    folder { "MyFolder" }
    name { "MyName" }
    checksum { "MyChecksum" }
  end
end
