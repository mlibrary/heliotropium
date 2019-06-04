# frozen_string_literal: true

class Identifier < ApplicationRecord
  include Filterable

  scope :name_like, ->(like) { where("name like ?", "%#{like}%") }

  has_one :uuid_identifier
  has_one :uuid, through: :uuid_identifier

  validates :name, presence: true, allow_blank: false, uniqueness: true

  def aliases
    Identifier.find(UuidIdentifier.where.not(identifier_id: id).where(uuid: uuid).map(&:identifier_id))
  end

  def update?
    true
  end

  def destroy?
    uuid.blank?
  end

  def resource_type
    type
  end

  def resource_id
    id
  end

  def resource_token
    @resource_token ||= resource_type.to_s + ':' + resource_id.to_s
  end

  protected

    def type
      @type ||= :Identifier
    end
end
