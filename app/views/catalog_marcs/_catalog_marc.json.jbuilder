# frozen_string_literal: true

json.extract! catalog_marc, :id, :folder, :file, :isbn, :doi, :mrc, :updated, :valid, :created_at, :updated_at
json.url catalog_marc_url(catalog_marc, format: :json)
