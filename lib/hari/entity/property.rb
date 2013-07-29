module Hari
  class Entity
    class Property
      autoload :Builder, 'hari/entity/property/builder'

      attr_accessor :name, :serializer, :options

      def initialize(name, options = {})
        @name, @options = name.to_s, options
        @serializer = options.delete(:type) || Serialization::String
      end

      def serialize(value)
        serializer.serialize value, name: name
      end

      def desserialize(value)
        serializer.desserialize value, name: name
      end

    end
  end
end
