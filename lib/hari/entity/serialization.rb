module Hari
  class Entity
    module Serialization
      extend ActiveSupport::Concern

      included do
        include ActiveModel::Validations
        include ActiveModel::Dirty
        extend  Property::Builder
      end

      autoload :Array,    'hari/entity/serialization/array'
      autoload :Boolean,  'hari/entity/serialization/boolean'
      autoload :Date,     'hari/entity/serialization/date'
      autoload :DateTime, 'hari/entity/serialization/datetime'
      autoload :Float,    'hari/entity/serialization/float'
      autoload :Hash,     'hari/entity/serialization/hash'
      autoload :Integer,  'hari/entity/serialization/integer'
      autoload :String,   'hari/entity/serialization/string'
      autoload :Time,     'hari/entity/serialization/time'

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

      def to_hash
        self.class.properties.inject({}) do |buffer, prop|
          buffer.merge prop.name => prop.serialize(send(prop.name))
        end
      end

      def to_json
        Yajl::Encoder.encode to_hash
      end

      module ClassMethods

        def from_hash(source)
          hash = source.inject({}) do |buffer, (key, value)|
            if prop = properties.find { |p| p.name == key }
              buffer[key] = prop.desserialize(value)
            end

            buffer
          end

          new hash
        end

        def from_json(source)
          return if source.blank?

          case source
          when ::String
            from_hash Yajl::Parser.parse(source)
          when ::Hash
            from_hash source
          end
        end

      end

    end
  end
end
