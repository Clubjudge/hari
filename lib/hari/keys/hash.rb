module Hari
  module Keys
    class Hash < Key
      include Collection

      def hash(name = nil)
        return super() unless name

        @name = name
        self
      end

      def hash!(name)
        @name = name
        to_h
      end

      def to_h
        Hari.redis.hgetall key
      end

      def to_a
        to_h.to_a
      end

      def delete(field)
        Hari.redis.hdel key, field
      end

      def key?(field)
        Hari.redis.hexists key, field
      end

      alias :has_key? :key?
      alias :member?  :key?

      def keys
        Hari.redis.hkeys key
      end

      def values
        Hari.redis.hvals key
      end

      def values_at(*keys)
        Hari.redis.hmget key, keys
      end

      def [](field)
        Hari.redis.hget key, field
      end

      def set(field, value)
        Hari.redis.hset key, field, value
      end

      alias :[]= :set

      def merge!(args = {})
        Hari.redis.hmset key, args.to_a.flatten
      end

      def size
        Hari.redis.hlen key
      end

      alias :length :size

    end
  end
end
