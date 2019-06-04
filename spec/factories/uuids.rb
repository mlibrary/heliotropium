# frozen_string_literal: true

FactoryBot.define do
  factory :uuid do
    packed do
      uuid_packed = []
      16.times { uuid_packed.push(rand(16)) }
      uuid_packed.pack('C*').force_encoding('ascii-8bit')
    end
    after(:build) { |uuid| uuid.unpacked = Uuid.uuid_unpack(uuid.packed) }
  end
end
