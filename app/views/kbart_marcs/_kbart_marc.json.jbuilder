# frozen_string_literal: true

json.extract! kbart_marc, :id, :folder, :doi, :mrc, :created_at, :updated_at
json.url kbart_marc_url(kbart_marc, format: :json)
