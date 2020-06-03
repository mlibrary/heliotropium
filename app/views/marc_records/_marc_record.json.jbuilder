# frozen_string_literal: true

json.extract! marc_record, :id, :folder, :file, :doi, :mrc, :updated, :created_at, :updated_at
json.url marcRecord_url(marc_record, format: :json)
