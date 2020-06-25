# frozen_string_literal: true

class KbartMarc < ApplicationRecord
  include Filterable

  scope :folder_like, ->(like) { where("folder like ?", "%#{like}%") }
  scope :file_like, ->(like) { where("file like ?", "%#{like}%") }
  scope :doi_like, ->(like) { where("doi like ?", "%#{like}%") }
  scope :updated_like, ->(like) { where("updated like ?", Date.parse(like).to_s) }

  validates :folder, presence: true, allow_blank: false
  validates :file, presence: true, allow_blank: false
  validates :doi, presence: true, allow_blank: false

  def update?
    true
  end

  def destroy?
    true
  end
end
