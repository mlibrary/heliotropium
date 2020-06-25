# frozen_string_literal: true

FactoryBot.define do
  factory :kbart_marc do
    folder { "MyFolder" }
    file { "MyFile" }
    doi { "MyDOI" }
  end
end
