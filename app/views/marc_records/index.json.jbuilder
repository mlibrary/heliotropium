# frozen_string_literal: true

json.array! @marc_records, partial: "marc_records/marc_record", as: :marc_record
