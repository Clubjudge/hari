module Hari
  class Entity
    module Serialization
      extend ActiveSupport::Concern

      autoload :Boolean,  'hari/entity/serialization/boolean'
      autoload :Date,     'hari/entity/serialization/date'
      autoload :DateTime, 'hari/entity/serialization/datetime'
      autoload :Float,    'hari/entity/serialization/float'
      autoload :Integer,  'hari/entity/serialization/integer'
      autoload :String,   'hari/entity/serialization/string'
      autoload :Time,     'hari/entity/serialization/time'

      def to_json
        hash = self.class.properties.inject({}) do |buffer, prop|
          buffer.merge prop.name => prop.serialize(send(prop.name))
        end

        Yajl::Encoder.encode hash
      end

      module ClassMethods

        def from_json(source)
          return if source.blank?

          attrs = Yajl::Parser.parse(source).inject({}) do |buffer, (key, value)|
            if prop = properties.find { |p| p.name == key }
              buffer[key] = prop.desserialize(value)
            end

            buffer
          end

          new attrs
        end

      end

    end
  end
end
