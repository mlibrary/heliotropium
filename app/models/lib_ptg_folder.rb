# frozen_string_literal: true

class LibPtgFolder < ApplicationRecord
  include Filterable

  scope :name_like, ->(like) { where("name like ?", "%#{like}%") }

  validates :name, presence: true, allow_blank: false, uniqueness: true

  def update?
    true
  end

  def destroy?
    true
  end
end
