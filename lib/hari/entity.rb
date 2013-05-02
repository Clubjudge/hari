require 'hari/entity/property'
require 'hari/entity/repository'
require 'hari/entity/serialization'

module Hari
  class Entity
    extend  ActiveModel::Naming
    extend  ActiveModel::Callbacks
    include ActiveModel::Validations
    extend  Property::Builder
    include Repository
    include Serialization

    define_model_callbacks :create, :update, :destroy, :save

    property :id
    property :created_at, type: Time
    property :updated_at, type: Time

    def initialize(attrs = {})
      return if attrs.blank?

      attrs = attrs.with_indifferent_access

      self.class.properties.each do |prop|
        send("#{prop.name}=", attrs[prop.name]) if attrs[prop.name]
      end
    end

    def attributes
      self.class.properties.inject({}) do |buffer, prop|
        buffer.merge prop.name => send(prop.name)
      end
    end

    alias attribute send
    alias read_attribute send

    def write_attribute(name, value)
      send "#{name}=", value
    end

    def has_attribute?(name)
      respond_to? name
    end

    def ==(other)
      other.is_a?(Hari::Entity) && self.id == other.id
    end

    def new?
      self.id.nil?
    end

    alias new_record? new?

    def persisted?
      not new?
    end

    def destroyed?
      @destroyed
    end

    def generate_id
      'ent' + ::Time.now.strftime('%Y%m%d%H%M%S') + SecureRandom.hex(3)
    end

    def to_s
      attrs = attributes
      attrs.delete 'id'

      "<#{self.class} id='#{id}' attributes=#{attrs}>"
    end

  end
end
