# frozen_string_literal: true

class UuidIdentifier < ApplicationRecord
  belongs_to :uuid
  belongs_to :identifier
end
