# frozen_string_literal: true

class KbartMarc < ApplicationRecord
  include Filterable

  scope :folder_like, ->(like) { where("folder like ?", "%#{like}%") }
  scope :doi_like, ->(like) { where("doi like ?", "%#{like}%") }
  scope :year_like, ->(like) { where("year like ?", "%#{like}%") }

  validates :folder, presence: true, allow_blank: false
  validates :doi, presence: true, allow_blank: false
  validates :folder, uniqueness: { scope: :doi }

  def update?
    true
  end

  def destroy?
    true
  end
end
