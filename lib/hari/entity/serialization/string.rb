module Hari
  class Entity
    module Serialization
      module String

        def self.serialize(value, options = {})
          value.to_s if value
        end

        def self.desserialize(value, options = {})
          value
        end

      end
    end
  end
end
