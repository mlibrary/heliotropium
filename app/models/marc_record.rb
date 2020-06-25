# frozen_string_literal: true

class MarcRecord < ApplicationRecord
  include Filterable

  scope :folder_like, ->(like) { where("folder like ?", "%#{like}%") }
  scope :file_like, ->(like) { where("file like ?", "%#{like}%") }
  scope :doi_like, ->(like) { where("doi like ?", "%#{like}%") }
  scope :updated_like, ->(like) { where("updated like ?", Date.parse(like).to_s) }
  scope :parsed_like, ->(like) { where("parsed like ?", "%#{like}%") }
  scope :replaced_like, ->(like) { where("replaced like ?", "%#{like}%") }
  scope :selected_like, ->(like) { where("selected like ?", "%#{like}%") }
  scope :count_like, ->(like) { where("not count like ?", "%#{like}%") }

  validates :folder, presence: true, allow_blank: false
  validates :file, presence: true, allow_blank: false
  validates :folder, uniqueness: { scope: :file }

  def update?
    true
  end

  def destroy?
    true
  end
end
