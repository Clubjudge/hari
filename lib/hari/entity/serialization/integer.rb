module Hari
  class Entity
    module Serialization
      module Integer

        def self.serialize(value, options = {})
          desserialize value, options
        end

        def self.desserialize(value, options = {})
          return unless value

          Integer value
        rescue
          raise SerializationError, "#{options[:name]}:#{value} is not an integer"
        end

      end
    end
  end
end
