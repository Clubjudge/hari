module Hari
  class Entity
    class Property
      autoload :Builder, 'hari/entity/property/builder'

      attr_accessor :entity, :name, :serializer, :options

      def initialize(entity, name, options = {})
        @entity, @name, @options = entity, name.to_s, options
        @serializer = options.delete(:type) || Serialization::String
      end

      def default
        case options[:default]
        when Proc
          options[:default].call
        else
          options[:default]
        end
      end

      def serialize(entity)
        value = entity.attribute(name)

        if value.nil?
          value = entity.write_attribute(name, default)
        end

        serializer.serialize value, name: name
      end

      def desserialize(value)
        serializer.desserialize value, name: name
      end

    end
  end
end
