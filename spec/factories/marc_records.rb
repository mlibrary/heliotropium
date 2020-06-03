# frozen_string_literal: true

FactoryBot.define do
  factory :marc_record do
    folder { "MyFolder" }
    file { "MyFile" }
    doi { "MyDOI" }
    mrc { "" }
    updated { "2019-08-01 13:25:18" }
    parsed { false }
  end
end
