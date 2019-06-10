# frozen_string_literal: true

json.extract! lib_ptg_folder, :id, :name, :flavor, :month, :touched, :created_at, :updated_at
json.url lib_ptg_folder_url(lib_ptg_folder, format: :json)
