module Hari
  class Entity
    module Serialization
      module Hash

        def self.serialize(value, options = {})
          if value.blank?
            {}
          elsif value.respond_to?(:to_hash)
            value.to_hash
          elsif value.respond_to?(:to_h)
            value.to_h
          elsif value.respond_to?(:marshal_dump)
            value.marshal_dump
          else
            fail 'value not accepted as a Hash'
          end
        end

        def self.desserialize(value, options = {})
          value
        end

        def self.method_missing(method, *args, &block)
          ::Hash.send method, *args, &block
        end

      end
    end
  end
end
