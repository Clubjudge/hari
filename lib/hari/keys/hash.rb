module Hari
  module Keys
    #
    # Enables Redis Hashes in Hari.
    # Redis Hashes are maps between string fields and string values.
    #
    # @see http://redis.io/commands#hash
    #
    class Hash < Key
      include Collection

      # Sets hash name
      #
      # @return [self]
      #
      def hash(name = nil)
        return super() unless name

        @name = name
        self
      end

      # Sets hash name and retrieves its data
      #
      # @return [Hash]
      #
      def hash!(name)
        hash(name).to_h
      end

      # @see http://redis.io/commands/hgetall
      #
      # @return [Hash]
      #
      def to_h
        redis.hgetall key
      end

      # @see http://redis.io/commands/hgetall
      #
      # @return [Array]
      #
      def to_a
        to_h.to_a
      end

      # @see http://redis.io/commands/hdel
      #
      # @return [Fixnum] number of removed members
      #
      def delete(field)
        redis.hdel key, field
      end

      # @see http://redis.io/commands/hexists
      #
      # @return [true, false]
      #
      def key?(field)
        redis.hexists key, field
      end

      alias :has_key? :key?
      alias :member?  :key?

      # @see http://redis.io/commands/hkeys
      #
      # @return [Array<String>]
      #
      def keys
        redis.hkeys key
      end

      # @see http://redis.io/commands/hvals
      #
      # @return [Array<String>]
      #
      def values
        redis.hvals key
      end

      # @see http://redis.io/commands/hmget
      #
      # @return [Array<String>]
      #
      def values_at(*keys)
        redis.hmget key, keys
      end

      # @see http://redis.io/commands/hget
      #
      # @return [String, Object]
      #
      def [](field)
        redis.hget key, field
      end

      # @see http://redis.io/commands/hset
      #
      # @return [0, 1] 1 if field was created
      #                0 if field was updated
      #
      def set(field, value)
        redis.hset key, field, value
      end

      alias :[]= :set

      # @see http://redis.io/commands/hmset
      #
      # @return ['OK']
      #
      def merge!(args = {})
        redis.hmset key, args.to_a.flatten
      end

      # @see http://redis.io/commands/hlen
      #
      # @return [Fixnum]
      #
      def size
        redis.hlen key
      end

      alias :length :size

    end
  end
end
