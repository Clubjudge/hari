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
        hash(name).to_h
      end

      def to_h
        redis.hgetall key
      end

      def to_a
        to_h.to_a
      end

      def delete(field)
        redis.hdel key, field
      end

      def key?(field)
        redis.hexists key, field
      end

      alias :has_key? :key?
      alias :member?  :key?

      def keys
        redis.hkeys key
      end

      def values
        redis.hvals key
      end

      def values_at(*keys)
        redis.hmget key, keys
      end

      def [](field)
        redis.hget key, field
      end

      def set(field, value)
        redis.hset key, field, value
      end

      alias :[]= :set

      def merge!(args = {})
        redis.hmset key, args.to_a.flatten
      end

      def size
        redis.hlen key
      end

      alias :length :size

    end
  end
end
