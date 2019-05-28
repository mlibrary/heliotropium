# frozen_string_literal: true

class Resource
  private_class_method :new

  attr_reader :uuid

  # Class Methods

  def self.null_resource(uuid = '00000000-0000-0000-0000-000000000000')
    NullResource.send(:new, uuid)
  end

  # Instance Methods

  def valid?
    !instance_of?(NullResource)
  end

  def resource_type
    type
  end

  def resource_id
    uuid
  end

  def resource_token
    @resource_token ||= resource_type.to_s + ':' + resource_id.to_s
  end

  protected

    def type
      @type ||= /^Mighrax::(.+$)/.match(self.class.to_s)[1].to_sym
    end

  private

    def initialize(uuid)
      @uuid = uuid
    end
end

class NullResource < Resource
  private_class_method :new

  private

    def initialize(uuid)
      super(uuid)
    end
end
