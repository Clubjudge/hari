module Hari
  class Entity
    module Serialization
      extend ActiveSupport::Concern

      autoload :Array,    'hari/entity/serialization/array'
      autoload :Boolean,  'hari/entity/serialization/boolean'
      autoload :Date,     'hari/entity/serialization/date'
      autoload :DateTime, 'hari/entity/serialization/datetime'
      autoload :Float,    'hari/entity/serialization/float'
      autoload :Hash,     'hari/entity/serialization/hash'
      autoload :Integer,  'hari/entity/serialization/integer'
      autoload :String,   'hari/entity/serialization/string'
      autoload :Time,     'hari/entity/serialization/time'

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
