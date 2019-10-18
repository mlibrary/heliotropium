# frozen_string_literal: true

json.extract! umpebc_file, :id, :name, :checksum, :created_at, :updated_at
json.url umpebc_file_url(umpebc_file, format: :json)
