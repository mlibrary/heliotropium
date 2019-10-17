# frozen_string_literal: true

json.extract! umpebc_marc, :id, :doi, :mrc, :created_at, :updated_at
json.url umpebc_marc_url(umpebc_marc, format: :json)
