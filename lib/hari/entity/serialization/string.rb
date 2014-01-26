module Hari
  class Entity
    module Serialization
      module String

        # Returns the value as a String, if it's not nil
        #
        # @param value [#to_s, nil]
        # @param options [Hash] not using any options now
        #
        # @return [String, nil]
        #
        def self.serialize(value, options = {})
          value.try :to_s
        end

        # @param (see .serialize)
        #
        # @return [String, nil]
        #
        def self.desserialize(value, options = {})
          serialize value, options
        end

      end
    end
  end
end
