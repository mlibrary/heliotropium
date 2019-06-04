# frozen_string_literal: true

json.array! @uuid_identifiers, partial: "uuid_identifiers/uuid_identifier", as: :uuid_identifier
