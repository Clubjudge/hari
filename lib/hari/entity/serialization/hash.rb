module Hari
  class Entity
    module Serialization
      module Hash

        def self.serialize(value, options = {})
          if value.blank?
            {}
          elsif value.kind_of?(Hash)
            value
          elsif value.respond_to?(:to_h)
            value.to_h
          else
            fail 'value not accepted as a Hash'
          end
        end

        def self.desserialize(value, options = {})
          value
        end

      end
    end
  end
end
