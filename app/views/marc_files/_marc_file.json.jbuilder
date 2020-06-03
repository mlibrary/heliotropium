# frozen_string_literal: true

json.extract! marc_file, :id, :folder, :name, :checksum, :created_at, :updated_at
json.url marcFile_url(marc_file, format: :json)
