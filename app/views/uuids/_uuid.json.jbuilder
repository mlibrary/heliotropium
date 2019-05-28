# frozen_string_literal: true

json.extract! uuid, :id, :packed, :unpacked, :created_at, :updated_at
json.url uuid_url(uuid, format: :json)
