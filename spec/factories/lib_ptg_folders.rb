# frozen_string_literal: true

FactoryBot.define do
  factory :lib_ptg_folder do
    name { "UMPEBC_1970_1970_01_01" }
    flavor { "year" }
    month { 0 }
    touched { "1970-01-01" }
  end
end
