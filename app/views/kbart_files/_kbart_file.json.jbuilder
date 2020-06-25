# frozen_string_literal: true

json.extract! kbart_file, :id, :folder, :name, :updated, :created_at, :updated_at
json.url kbart_file_url(kbart_file, format: :json)
