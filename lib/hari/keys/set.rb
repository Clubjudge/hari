module Hari
  module Keys
    #
    # Enables Redis Sets in Hari.
    # Sets are unordered collection of Strings.
    #
    # @see http://redis.io/commands#set
    #
    class Set < Key
      include Collection

      # Sets the set name
      #
      # @return [self]
      #
      def set(name)
        @name = name
        self
      end

      # Sets the set name and retrieve
      # its members
      #
      # @return [Array<Object>]
      #
      def set!(name)
        set(name).members
      end

      # @see http://redis.io/commands/smembers
      #
      # @return [Array<Object>]
      #
      def members
        desserialize redis.smembers(key)
      end

      alias :to_a :members

      # @see http://redis.io/commands/srandmember
      #
      # @return [Object]
      #
      def rand(count = 1)
        desserialize redis.srandmember(key, count)
      end

      # @see http://redis.io/commands/scard
      #
      # @return [Fixnum]
      #
      def size
        redis.scard key
      end

      alias :length :size

      # @see http://redis.io/commands/sismember
      #
      # @return [true, false]
      #
      def include?(member)
        redis.sismember key, serialize(member)
      end

      alias :member? :include?

      # @see http://redis.io/commands/sadd
      #
      # @return [Fixnum] number of members created
      #
      def add(*members)
        redis.sadd key, serialize(members)
      end

      # @see http://redis.io/commands/sadd
      #
      # @return (see #add)
      #
      def <<(member)
        add member
      end

      # @see http://redis.io/commands/srem
      #
      # @return [Fixnum] number of members removed
      #
      def delete(*members)
        redis.srem key, serialize(members)
      end

      # @see http://redis.io/commands/spop
      #
      # @return [Object, nil]
      #
      def pop
        desserialize redis.spop(key)
      end

      # @see http://redis.io/commands/sinter
      #
      # @return [Array<Object>]
      #
      def intersect(*set_queries)
        desserialize redis.sinter(key, set_query_keys(set_queries))
      end

      # @see http://redis.io/commands/sinter
      #
      # @return [Array<Object>]
      #
      def &(other_set_query)
        intersect other_set_query
      end

      # @see http://redis.io/commands/sdiff
      #
      # @return [Array<Object>]
      #
      def diff(*set_queries)
        desserialize redis.sdiff(key, set_query_keys(set_queries))
      end

      # @see http://redis.io/commands/sdiff
      #
      # @return [Array<Object>]
      #
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
