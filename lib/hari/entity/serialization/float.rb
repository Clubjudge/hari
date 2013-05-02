module Hari
  class Entity
    module Serialization
      module Float

        def self.serialize(value, options = {})
          desserialize value, options
        end

        def self.desserialize(value, options = {})
          return unless value

          Float value
        rescue
          raise SerializationError, "#{options[:name]}:#{value} is not a float"
        end

      end
    end
  end
end
