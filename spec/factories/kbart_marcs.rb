# frozen_string_literal: true

FactoryBot.define do
  factory :kbart_marc do
    folder { "MyFolder" }
    doi { "MyDOI" }
    year { 1970 }
  end
end
