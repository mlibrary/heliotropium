# frozen_string_literal: true

class LibPtgBox < ApplicationRecord
  include Filterable

  scope :name_like, ->(like) { where("name like ?", "%#{like}%") }

  def update?
    true
  end

  def destroy?
    true
  end
end
