# frozen_string_literal: true

json.array! @kbart_files, partial: "kbart_files/kbart_file", as: :kbart_file
