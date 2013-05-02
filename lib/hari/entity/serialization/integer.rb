module Hari
  class Entity
    module Serialization
      module Integer

        def self.serialize(value, options = {})
          desserialize value, options
        end

        def self.desserialize(value, options = {})
          case value
          when ::String
            if value =~ /^\d+$/
              value.to_i
            else
              raise
            end
          else
            Integer(value)
          end
        rescue
          raise SerializationError, "#{options[:name]}:#{value} is not an integer"
        end

      end
    end
  end
end
