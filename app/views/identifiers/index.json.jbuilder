# frozen_string_literal: true

json.array! @identifiers, partial: "identifiers/identifier", as: :identifier
