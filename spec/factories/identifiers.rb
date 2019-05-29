# frozen_string_literal: true

FactoryBot.define do
  factory :identifier do
    sequence(:name) { |n| "IdentifierName#{n}" }
  end
end
