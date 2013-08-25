module Hari
  module Keys
    class SortedSet < Key

      def sorted_set(name)
        @name = name
        self
      end

      def sorted_set!(name)
        @name = name
        members
      end

      def range(start = 0, stop = -1, options = {})
        return revrange(start, stop, options) if options[:desc]

        result = Hari.redis.zrange key, start, stop,
          options.slice(:with_scores)

        desserialize result
      end

      alias :members :range

      def range_with_scores
        range 0, -1, with_scores: true
      end

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

      def range_by_score(min, max, options = {})
        return revrange_by_score(min, max, options) if options[:desc]

        result = Hari.redis.zrangebyscore key, min, max,
          options.slice(:with_scores, :limit)

        desserialize result
      end

      def revrange_by_score(min, max, options = {})
        result = Hari.redis.zrevrangebyscore key, max, min,
          options.slice(:with_scores, :limit)

        desserialize result
      end

      def rank(member, options = {})
        return revrank(member, options) if options[:desc]

        Hari.redis.zrank key, member
      end

      alias :ranking  :rank
      alias :position :rank

      def revrank(member)
        Hari.redis.zrevrank key, serialize(member)
      end

      alias :reverse_ranking  :revrank
      alias :reverse_position :revrank

      def count
        Hari.redis.zcard key
      end

      alias :size :count
      alias :length :count

      def empty?
        count == 0
      end

      def one?
        count == 1
      end

      def many?
        count > 1
      end

      def include?(member)
        score(member).present?
      end

      alias :member? :include?

      def score(member)
        Hari.redis.zscore key, serialize(member)
      end

      def add(*score_members)
        Hari.redis.zadd key, serialize(score_members.to_a.flatten)
      end

      def <<(*score_members)
        add score_members
      end

      def delete(*members)
        Hari.redis.zrem key, serialize(members)
      end

      def trim_by_rank(start, stop)
        Hari.redis.zremrangebyrank key, start, stop
      end

      def trim_by_score(min, max)
        Hari.redis.zremrangebyscore key, min, max
      end

    end
  end
end
