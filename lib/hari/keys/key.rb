module Hari
  module Keys
    #
    # This is the superclass for all keys in Hari.
    #
    # It contains some of the methods every key have in Redis.
    #
    # @see http://redis.io/commands#generic
    #
    class Key

      # When a key belongs to a hari node, its redis key
      # will be namespaced properly
      #
      # @return [Hari::Node, nil] parent node, if any
      #
      attr_reader :node

      # The key name not considering the namespaced prefixes
      #
      # @return [String]
      #
      attr_reader :name

      # { type }
      # @return [Hash]
      #
      attr_reader :options

      def initialize(node = nil, options = {})
        @node, @options = node, options
      end

      #
      # @return [String] the redis key
      #
      def key
        @key ||= begin
          prefix = node ? "#{node.node_key}:" : ''
          prefix + name.to_s
        end
      end

      # Removes the key
      #
      # @see http://redis.io/commands/del
      #
      # @return [true] if key was removed
      # @return [false] if key does not exist
      #
      def delete!
        redis.del(key) == 1
      end

      # Returns if key exists
      #
      # @see http://redis.io/commands/exists
      #
      # @return [true] if key exists
      # @return [false] if key does not exist
      #
      def exists?
        redis.exists key
      end

      # Set a timeout in milliseconds
      #
      # @see http://redis.io/commands/pexpire
      #
      # @param [Integer] milliseconds
      #
      # @return [true] if timeout was set
      # @return [false] if key does not exist or timeout could not be set
      #
      def expire(milliseconds)
        redis.pexpire key, milliseconds
      end

      # Set a timeout from a timestamp
      #
      # @see http://redis.io/commands/expireat
      #
      # @param [Time] timestamp to expire key
      #
      # @return [true] if timeout was set
      # @return [false] if key does not exist or timeout could not be set
      #
      def expire_at(timestamp)
        redis.expireat key, ::Time.parse(timestamp).to_i
      end

      # Removes existing timeouts on key
      #
      # @see http://redis.io/commands/persist
      #
      # @return [true] if timeout was removed
      #
      # @return [false] if key does not exist or does not have an
      #                 associated timeout
      def persist
        redis.persist key
      end

      # Returns the type of the value at key
      #
      # @see http://redis.io/commands/type
      #
      # @return [String] representation of the type of the
      #                  value stored at key, which can be:
      #                  string, list, set, zset, hash
      #
      def type
        redis.type key
      end

      # Returns the remaining time to live when a key has a timeout
      #
      # @see http://redis.io/commands/pttl
      #
      # @return [Integer] ttl in milliseconds, or negative number when
      #                   key does not exist / exists with no expire
      #
      def ttl
        redis.pttl key
      end

      # Serializes values to be stored in Redis.
      #
      # @param [#to_json, Array<#to_json>] elements to be serialized
      #
      # @return [String] serialized value
      #
      def serialize(value)
        type = options[:type]
        return value if type.nil? || value.nil?

        value.respond_to?(:each) ? value.map(&:to_json) : value.to_json
      end

      # Desserializes values stored in Redis.
      #
      # @param value the value to be desserialized
      #              according to its content and
      #              the key type
      #
      # @return desserialized value.
      #         returns nil if value is nil or there is no type,
      #         otherwise returns desserialized value
      #
      def desserialize(value)
        type = options[:type]
        return value if type.nil? || value.nil?

        value.respond_to?(:each) ? value.map(&type.method(:from_json))
                                 : type.from_json(value)
      end

      private

      # Returns the Hari redis client
      #
      # @return [Redis] redis client
      #
      def redis
        Hari.redis
      end

    end
  end
end
