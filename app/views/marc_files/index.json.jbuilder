# frozen_string_literal: true

json.array! @marc_files, partial: "marc_files/marc_file", as: :marc_file
