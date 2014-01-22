module Hari
  class Node
    class Index

      attr_accessor :property, :value, :indexes, :options

      attr_writer :start, :stop

      def initialize(property, value)
        @property, @value  = property, value
        @indexes, @options = [], {}
      end

      def add(node)
        Hari.redis.zadd key, Time.now.to_f, node.model_id
      end

      def delete(node)
        Hari.redis.zrem key, node.model_id
      end

      def append(index)
        self.tap { |i| i.indexes << index }
      end

      def start
        @start ||= 0
      end

      def stop
        @stop ||= -1
      end

      def limit(page = nil, per_page = nil)
        if page.present? && per_page.present?
          self.start = page * per_page
          self.stop  = start + per_page - 1
        end

        self
      end

      def from(score, direction = nil)
        direction ||= :up
        options[:from] = { score: score.to_f, direction: direction.to_s }

        self
      end

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
