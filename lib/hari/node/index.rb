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
        self.indexes << index

        self
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

      def list
        if indexes.empty?
          ids = Hari.redis.zrevrange(key, start, stop)
        else
          intersect

          ids = Hari.redis.zrevrange(intersect_key, start, stop).tap do
            Hari.redis.del intersect_key
          end
        end

        property.entity.find *ids
      end

      alias :to_a   :list
      alias :result :list

      def key
        "#{property.entity.node_type}|#{property.name}:#{digest(value)}"
      end

      private

      def digest(value)
        Digest::MD5.hexdigest value
      end

      def intersect
        Hari.redis.zinterstore intersect_key, [key] + indexes.map(&:key)
      end

      def intersect_key
        "inter:#{key}:#{indexes.map(&:key).join(':')}"
      end

    end
  end
end
