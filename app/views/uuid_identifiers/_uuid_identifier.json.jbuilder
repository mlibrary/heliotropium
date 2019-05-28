# frozen_string_literal: true

json.extract! uuid_identifier, :id, :uuid_id, :identifier_id, :created_at, :updated_at
json.url uuid_identifier_url(uuid_identifier, format: :json)
