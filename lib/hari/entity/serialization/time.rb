module Hari
  class Entity
    module Serialization
      module Time

        def self.serialize(value, options = {})
          desserialize(value, options).try :strftime, '%Y%m%d%H%M%S'
        end

        def self.desserialize(value, options = {})
          return unless value.present?

          value.kind_of?(::Time) ? value : ::Time.parse(value)
        rescue
          raise SerializationError, "#{options[:name]}:#{value} is an invalid time"
        end

      end
    end
  end
end
