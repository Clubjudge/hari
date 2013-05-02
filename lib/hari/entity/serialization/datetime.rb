module Hari
  class Entity
    module Serialization
      module DateTime

        def self.serialize(value, options = {})
          desserialize(value, options).try :iso8601
        end

        def self.desserialize(value, options = {})
          return unless value.present?

          value.kind_of?(::DateTime) ? value : ::DateTime.parse(value)
        rescue
          raise SerializationError, "#{options[:name]}:#{value} is an invalid date time"
        end

      end
    end
  end
end
