module Hari
  class Entity
    module Serialization
      module Boolean

        MAPPINGS  = {
          true    => true,
          'true'  => true,
          'TRUE'  => true,
          '1'     => true,
          1       => true,
          1.0     => true,
          'x'     => true,
          'X'     => true,
          't'     => true,
          'T'     => true,
          false   => false,
          'false' => false,
          'FALSE' => false,
          '0'     => false,
          0       => false,
          0.0     => false,
          ''      => false,
          ' '     => false,
          'f'     => false,
          'F'     => false,
          nil     => false
        }.freeze

        def self.serialize(value, options = {})
          MAPPINGS[value].tap do |bool|
            fail SerializationError, "#{options[:name]}:#{value} is not boolean" if bool.nil?
          end
        end

        def self.desserialize(value, options = {})
          serialize value, options
        end

      end
    end
  end
end
