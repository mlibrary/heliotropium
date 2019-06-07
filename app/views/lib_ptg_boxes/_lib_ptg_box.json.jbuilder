# frozen_string_literal: true

json.extract! lib_ptg_box, :id, :name, :flavor, :month, :updated, :created_at, :updated_at
json.url lib_ptg_box_url(lib_ptg_box, format: :json)
