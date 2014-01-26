module Hari
  module Keys
    class SortedSet < Key
      include Collection

      # Sets the sorted set name
      #
      # @return [self]
      #
      def sorted_set(name)
        @name = name
        self
      end

      # Creates a sorted set and retrieve
      # its members
      #
      # @return [Array<Object>]
      #
      def sorted_set!(name)
        sorted_set(name).members
      end

      # @see http://redis.io/commands/zrange
      #
      # @return [Array<Object>]
      #
      def range(start = 0, stop = -1, options = {})
        return revrange(start, stop, options) if options[:desc]

        result = Hari.redis.zrange key, start, stop,
          options.slice(:with_scores)

        desserialize result
      end

      alias :members :range
      alias :to_a    :range

      def range_with_scores
        range 0, -1, with_scores: true
      end

      # @see http://redis.io/commands/zrevrange
      #
      # @return [Array<Object>]
      #
      def revrange(start = 0, stop = -1, options = {})
        result = Hari.redis.zrevrange key, start, stop,
          options.slice(:with_scores)

        desserialize result
      end

      alias :reverse_range :revrange
      alias :desc_range    :revrange

      def revrange_with_scores
        revrange 0, -1, with_scores: true
      end

      # @see http://redis.io/commands/zrangebyscore
      #
      # @return [Array<Object>]
      #
      def range_by_score(min, max, options = {})
        return revrange_by_score(min, max, options) if options[:desc]

        result = Hari.redis.zrangebyscore key, min, max,
          options.slice(:with_scores, :limit)

        desserialize result
      end

      # @see http://redis.io/commands/zrevrangebyscore
      #
      # @return [Array<Object>]
      #
      def revrange_by_score(min, max, options = {})
        result = Hari.redis.zrevrangebyscore key, max, min,
          options.slice(:with_scores, :limit)

        desserialize result
      end

      # @see http://redis.io/commands/zrank
      #
      # @return [Fixnum, nil]
      #
      def rank(member, options = {})
        return revrank(member, options) if options[:desc]

        Hari.redis.zrank key, member
      end

      alias :ranking  :rank
      alias :position :rank

      # @see http://redis.io/commands/zrevrank
      #
      # @return [Fixnum, nil]
      #
      def revrank(member)
        Hari.redis.zrevrank key, serialize(member)
      end

      alias :reverse_ranking  :revrank
      alias :reverse_position :revrank

      # @see http://redis.io/commands/zcard
      #
      # @return [Fixnum]
      #
      def size
        Hari.redis.zcard key
      end

      alias :length :size

      # @see http://redis.io/commands/zscore
      #
      # @return [true, false]
      #
      def include?(member)
        score(member).present?
      end

      alias :member? :include?

      # @see http://redis.io/commands/zscore
      #
      # @return [Float, nil]
      #
      def score(member)
        Hari.redis.zscore key, serialize(member)
      end

      # @see http://redis.io/commands/zadd
      #
      # @return [Fixnum] number of created members
      #
      def add(*score_members)
        Hari.redis.zadd key, serialize(score_members.to_a.flatten)
      end

      # @see http://redis.io/commands/zadd
      #
      # @return (see #add)
      #
      def <<(*score_members)
        add score_members
      end

      # @see http://redis.io/commands/zrem
      #
      # @return [Fixnum] number of members removed
      #
      def delete(*members)
        Hari.redis.zrem key, serialize(members)
      end

      # @see http://redis.io/commands/zremrangebyrank
      #
      # @return [Fixnum] number of removed members
      #
      def trim_by_rank(start, stop)
        Hari.redis.zremrangebyrank key, start, stop
      end

      # @see http://redis.io/commands/zremrangebyscore
      #
      # @return [Fixnum] number of removed members
      #
      def trim_by_score(min, max)
        Hari.redis.zremrangebyscore key, min, max
      end

    end
  end
end
