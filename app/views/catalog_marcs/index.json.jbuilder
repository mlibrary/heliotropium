# frozen_string_literal: true

json.array! @catalog_marcs, partial: "catalog_marcs/catalog_marc", as: :catalog_marc
