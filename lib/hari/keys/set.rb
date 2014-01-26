module Hari
  module Keys
    class Set < Key
      include Collection

      def set(name)
        @name = name
        self
      end

      def set!(name)
        set(name).members
      end

      def members
        desserialize redis.smembers(key)
      end

      alias :to_a :members

      def rand(count = 1)
        desserialize redis.srandmember(key, count)
      end

      def size
        redis.scard key
      end

      alias :length :size

      def include?(member)
        redis.sismember key, serialize(member)
      end

      alias :member? :include?

      def add(*members)
        redis.sadd key, serialize(members)
      end

      def <<(member)
        add member
      end

      def delete(*members)
        redis.srem key, serialize(members)
      end

      def pop
        desserialize redis.spop(key)
      end

      def intersect(*set_queries)
        desserialize redis.sinter(key, set_query_keys(set_queries))
      end

      def &(other_set_query)
        intersect other_set_query
      end

      def diff(*set_queries)
        desserialize redis.sdiff(key, set_query_keys(set_queries))
      end

      def -(other_set_query)
        diff other_set_query
      end

      private

      def set_query_keys(set_queries)
        keys = set_queries.map do |query|
          ensure_set_query! query
          query.key
        end

        fail 'no query keys' if keys.empty?

        keys
      end

      def ensure_set_query!(query)
        unless query.kind_of? ::Hari::Keys::Set
          fail 'not a set query'
        end
      end

    end
  end
end
