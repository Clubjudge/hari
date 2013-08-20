module Hari
  class Entity
    module Serialization
      module Array

        def self.serialize(value, options = {})
          Array value
        end

        def self.desserialize(value, options = {})
          Array value
        end

        def self.method_missing(method, *args, &block)
          ::Array.send method, *args, &block
        end

      end
    end
  end
end
