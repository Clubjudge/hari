module Hari
  class Entity
    extend  ActiveModel::Naming
    extend  ActiveModel::Callbacks
    include ActiveModel::Validations

    autoload :Property,      'hari/entity/property'
    autoload :Repository,    'hari/entity/repository'
    autoload :Serialization, 'hari/entity/serialization'

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

    alias :attribute :send
    alias :read_attribute :send
    alias :has_attribute? :respond_to?
    alias :read_attribute_for_serialization :send

    def write_attribute(name, value)
      send "#{name}=", value
    end

    def ==(other)
      other.is_a?(Hari::Entity) && id == other.id
    end

    def new?
      id.nil?
    end

    alias :new_record? :new?

    def persisted?
      not new?
    end

    def destroyed?
      @destroyed
    end

    def generate_id
      '_e' + ::Time.now.strftime('%Y%m%d%H%M%S') + SecureRandom.hex(3)
    end

    def to_s
      attrs = attributes
      attrs.delete 'id'

      "<#{self.class} id='#{id}' attributes=#{attrs}>"
    end

  end
end
