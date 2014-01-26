module Hari
  class Node
    class Index

      attr_accessor :property, :value, :indexes, :options

      attr_writer :start, :stop

      def initialize(property, value)
        @property, @value  = property, value
        @indexes, @options = [], {}
      end

      # Adds a node in the index
      #
      # @param node [Hari::Node]
      #
      # @return [0, 1]
      #
      def add(node)
        Hari.redis.zadd key, Time.now.to_f, node.model_id
      end

      # Removes a node from the index
      #
      # @param node [Hari::Node]
      #
      # @return [0, 1]
      #
      def delete(node)
        Hari.redis.zrem key, node.model_id
      end

      # Appends an index query to an already
      # existing lazy quering being built.
      #
      # @param index [Index] new query to append
      #
      # @return [self]
      #
      def append(index)
        self.tap { |i| i.indexes << index }
      end

      # Start position to fetch data, defaults to 0
      #
      # @return [Fixnum]
      #
      def start
        @start ||= 0
      end

      # Stop position to fetch data, defaults to -1
      # (end of the list)
      #
      # @return [Fixnum]
      #
      def stop
        @stop ||= -1
      end

      # Limits query size
      #
      # @param page [Fixnum]
      # @param per_page [Fixnum]
      #
      # @return [Index] changed query
      #
      def limit(page = nil, per_page = nil)
        if page.present? && per_page.present?
          self.start = page * per_page
          self.stop  = start + per_page - 1
        end

        self
      end

      # Gets elements from a score position in the index,
      # optionally informing its direction (up | down),
      # defaulting to up.
      #
      # @param score [#to_f] timestamp of element
      # @param direction [#to_s] up | down (default: up)
      #
      # @result [Index] changed query
      #
      def from(score, direction = nil)
        direction ||= :up
        options[:from] = { score: score.to_f, direction: direction.to_s }

        self
      end

      # Counts elements that matches the query
      #
      # @return [Fixnum]
      #
      def count
        return count_intersect unless indexes.empty?

        from = options[:from]
        limit = stop == -1 ? stop : stop - start + 1

        if from.present? && from[:direction] == 'up'
          Hari.redis.zrevrangebyscore(key, '+inf', from[:score]).size
        elsif from.present? && from[:direction] == 'down'
          Hari.redis.zrevrangebyscore(key, from[:score], '-inf').size
        else
          Hari.redis.zcard key
        end
      end

      # Counts elements that matches the intersection
      # between several indexes
      #
      # @return [Fixnum]
      #
      def count_intersect
        intersect

        from = options[:from]
        limit = stop == -1 ? stop : stop - start + 1

        count = if from.present? && from[:direction] == 'up'
          Hari.redis.zrevrangebyscore(intersect_key, '+inf', from[:score]).size
        elsif from.present? && from[:direction] == 'down'
          Hari.redis.zrevrangebyscore(intersect_key, from[:score], '-inf').size
        else
          Hari.redis.zcard intersect_key
        end

        Hari.redis.del intersect_key

        count
      end

      # Lists elements that matches the query
      #
      # @return [Array<Hari::Node>]
      #
      def list
        return list_intersect unless indexes.empty?

        from = options[:from]
        limit = stop == -1 ? stop : stop - start + 1

        ids = if from.present? && from[:direction] == 'up'
          Hari.redis.zrevrangebyscore key, '+inf', from[:score], limit: [start, limit]
        elsif from.present? && from[:direction] == 'down'
          Hari.redis.zrevrangebyscore key, from[:score], '-inf', limit: [start, limit]
        else
          Hari.redis.zrevrange key, start, stop
        end

        property.entity.find_many ids
      end

      # Lists elements that matches the intersection
      # between several indexes
      #
      # @return [Array<Hari::Node>]
      #
      def list_intersect
        intersect

        from = options[:from]
        limit = stop == -1 ? stop : stop - start + 1

        ids = if from.present? && from[:direction] == 'up'
          Hari.redis.zrevrangebyscore intersect_key, '+inf', from[:score], limit: [start, limit]
        elsif from.present? && from[:direction] == 'down'
          Hari.redis.zrevrangebyscore intersect_key, from[:score], '-inf', limit: [start, limit]
        else
          Hari.redis.zrevrange intersect_key, start, stop
        end

        Hari.redis.del intersect_key

        property.entity.find_many ids
      end

      alias :to_a   :list
      alias :result :list

      # @return [String] the key for index in Redis
      def key
        "#{property.entity.node_type}|#{property.name}:#{digest(value)}"
      end

      private

      def digest(value)
        case value = value.to_s.strip
        when ''
          '_NULL_'
        when /^[[:alnum:]]+$/
          value
        else
          Digest::MD5.hexdigest value
        end
      end

      def intersect
        Hari.redis.zinterstore intersect_key, [key] + indexes.map(&:key), aggregate: 'max'
      end

      def intersect_key
        "inter:#{key}:#{indexes.map(&:key).join(':')}"
      end

    end
  end
end
