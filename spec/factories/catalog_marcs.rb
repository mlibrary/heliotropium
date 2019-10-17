# frozen_string_literal: true

FactoryBot.define do
  factory :catalog_marc do
    folder { "MyFolder" }
    file { "MyFile" }
    isbn { "MyISBN" }
    doi { "MyDOI" }
    mrc { "" }
    updated { "2019-08-01 13:25:18" }
    parsed { false }
  end
end
