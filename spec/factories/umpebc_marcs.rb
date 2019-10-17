# frozen_string_literal: true

FactoryBot.define do
  factory :umpebc_marc do
    doi { "MyDOI" }
    mrc { "MyMRC" }
    year { 1970 }
  end
end
