module Hari
  class Entity
    class Property
      autoload :Builder, 'hari/entity/property/builder'

      attr_accessor :entity, :name, :serializer, :options

      def initialize(entity, name, options = {})
        @entity, @name, @options = entity, name.to_s, options
        @serializer = options.delete(:type) || Serialization::String
      end

      # Returns default value, if there is any.
      #
      # When there's not a default, returns nil.
      # When default is a Proc, evaluates the proc in entity's context
      # Else, returns it's value.
      #
      # @param [Hari::Serialization] property's entity
      #
      def default(entity)
        case options[:default]
        when Proc
          entity.instance_eval options[:default]
        else
          options[:default]
        end
      end

      # Returns the value of property in entity serialized
      #
      # @param [Hari::Serialization] property's entity
      #
      def serialize(entity)
        value = entity.attribute(name)

        if value.nil?
          value = entity.write_attribute(name, default(entity))
        end

        serializer.serialize value, name: name
      end

      # @return desserialized value
      #
      def desserialize(value)
        serializer.desserialize value, name: name
      end

    end
  end
end
