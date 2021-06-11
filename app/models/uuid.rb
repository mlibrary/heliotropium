# frozen_string_literal: true

class Uuid < ApplicationRecord
  include Filterable

  scope :unpacked_like, ->(like) { where("unpacked like ?", "%#{like}%") }

  has_many :uuid_identifiers, dependent: :destroy
  has_many :identifiers, through: :uuid_identifiers

  validates :packed, presence: true, allow_blank: false, uniqueness: true
  validates :unpacked, presence: true, allow_blank: false, uniqueness: true

  class << self
    def factory(uuid)
      unpacked_uuid = if uuid.is_a?(String)
                        uuid_unpack(uuid_pack(uuid))
                      else
                        uuid_unpack(uuid)
                      end
      return Resource.null_resource(uuid) if /^00000000-0000-0000-0000-000000000000$/.match?(unpacked_uuid)

      Resource.send(:new, uuid)
    end

    def uuid_valid?(uuid)
      # 8-4-4-4-12 for a total of 36 characters (32 hexadecimal characters and 4 hyphens)
      /^[a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12}$/i.match?(uuid)
    end

    def uuid_null_packed
      Array.new(16, 0).pack('C*').force_encoding('ascii-8bit')
    end

    def uuid_null_unpacked
      '00000000-0000-0000-0000-000000000000'
    end

    def uuid_generator_packed
      uuid_pack(open('https://www.famkruithof.net/uuid/uuidgen').read.scan(/([-[:alnum:]]+)<\/h3>/)[0][0])
    end

    def uuid_generator_unpacked
      uuid_unpack(uuid_generator_packed)
    end

    def uuid_pack(unpacked) # rubocop:disable Metrics/MethodLength
      text = unpacked.dup
      text.delete!('-')
      return uuid_null_packed unless text.length == 32

      bytes = []
      16.times do |i|
        n = 2 * i
        bytes.push(("0x#{text[n]}#{text[n + 1]}").to_i(16))
      end
      bytes.pack('C*').force_encoding('ascii-8bit')
    rescue StandardError => _e
      uuid_null_packed
    end

    def uuid_unpack(packed) # rubocop:disable Metrics/MethodLength
      return uuid_null_unpacked unless packed.length == 16

      unpacked = []
      16.times do |i|
        byte = packed[i].bytes[0].to_s(16)
        unpacked.push(byte.length == 1 ? "0#{byte}" : byte)
      end
      unpacked = unpacked.join
      unpacked.insert(8, '-')
      unpacked.insert(13, '-')
      unpacked.insert(18, '-')
      unpacked.insert(23, '-')
      unpacked
    rescue StandardError => _e
      uuid_null_unpacked
    end

    def null
      Uuid.find_or_create_by(packed: uuid_null_packed, unpacked: uuid_null_unpacked)
    end

    def generator
      packed = uuid_generator_packed
      unpacked = uuid_unpack(packed)
      Uuid.create!(packed: packed, unpacked: unpacked)
    end
  end

  def update?
    false
  end

  def destroy?
    identifiers.blank?
  end

  def resource_type
    type
  end

  def resource_id
    id
  end

  def resource_token
    @resource_token ||= "#{resource_type}:#{resource_id}"
  end

  protected

    def type
      @type ||= :Uuid
    end
end
