module Hari
  class Entity
    #
    # This module provides property building,
    # attributes serialization, validation,
    # change tracking, and JSON encoding.
    #
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

      # Creates an instance with all attributes passed
      # (only the ones that have a matching property name)
      #
      # @param [Hash]
      #
      # @return [Hari::Entity::Serialization]
      #
      def initialize(attrs = {})
        return if attrs.blank?

        attrs = attrs.with_indifferent_access

        self.class.properties.each do |prop|
          write_attribute(prop.name, attrs[prop.name]) if attrs.key?(prop.name)
        end
      end

      # @return [Hash] all properties keys and values
      #
      def attributes
        self.class.properties.inject({}) do |buffer, prop|
          buffer.merge prop.name => send(prop.name)
        end
      end

      alias :attribute :send
      alias :read_attribute :send
      alias :has_attribute? :respond_to?
      alias :read_attribute_for_serialization :send

      # Sets property value
      #
      # @param name [String, Symbol] the attribute name
      #
      # @param value the attribute value
      #
      # @return value
      #
      def write_attribute(name, value)
        send "#{name}=", value
      end

      # @return [Hash] serialized hash with attributes
      #
      def to_hash
        self.class.properties.inject({}) do |buffer, prop|
          buffer.merge prop.name => prop.serialize(self)
        end
      end

      # @return [String] the object serialized in JSON format
      #
      def to_json
        Yajl::Encoder.encode to_hash
      end

      module ClassMethods

        # Mounts an instance of the class from a hash
        # containing its attributes keys and values
        #
        # @param source [Hash] the attributes to be desserialized
        #
        # @return [Hari::Entity::Serialization] the object mounted from the hash
        #
        def from_hash(source)
          hash = source.inject({}) do |buffer, (key, value)|
            if prop = properties.find { |p| p.name == key }
              buffer[key] = prop.desserialize(value)
            end

            buffer
          end

          new(hash).tap { |e| e.changed_attributes.clear }
        end

        # Mounts an instance of the class from a JSON
        # string containing its attributes keys and values
        #
        # @param source [String] the JSON attributes to be desserialized
        #
        # @return [Hari::Entity::Serialization, nil] the object mounted from JSON
        #
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
