# frozen_string_literal: true

class UmpebcMarc < ApplicationRecord
  include Filterable

  scope :doi_like, ->(like) { where("doi like ?", "%#{like}%") }

  validates :doi, presence: true, allow_blank: false, uniqueness: true

  def update?
    true
  end

  def destroy?
    true
  end
end
