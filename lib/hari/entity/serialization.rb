require 'hari/entity/serialization/boolean'
require 'hari/entity/serialization/date'
require 'hari/entity/serialization/datetime'
require 'hari/entity/serialization/float'
require 'hari/entity/serialization/integer'
require 'hari/entity/serialization/string'
require 'hari/entity/serialization/time'

module Hari
  class Entity
    module Serialization
      extend ActiveSupport::Concern

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
