# frozen_string_literal: true

module Support
  class << self
    def random_uuid_packed
      uuid_packed = []
      16.times { uuid_packed.push(rand(16)) }
      uuid_packed.pack('C*').force_encoding('ascii-8bit')
    end
  end
end
