# frozen_string_literal: true

class KbartFile < ApplicationRecord
  include Filterable

  scope :folder_like, ->(like) { where("folder like ?", "%#{like}%") }
  scope :name_like, ->(like) { where("name like ?", "%#{like}%") }

  validates :folder, presence: true, allow_blank: false
  validates :name, presence: true, allow_blank: false, uniqueness: true

  def update?
    true
  end

  def destroy?
    true
  end
end
