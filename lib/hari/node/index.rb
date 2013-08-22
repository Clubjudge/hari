module Hari
  class Node
    class Index

      attr_accessor :property, :value

      def initialize(property, value)
        @property, @value = property, value
      end

      def add(node)
        Hari.redis.zadd key, Time.now.to_f, node.model_id
      end

      def delete(node)
        Hari.redis.zrem key, node.model_id
      end

      def list(page = nil, per_page = nil)
        start = page.present? && per_page.present? ? page * per_page : 0
        stop  = page.present? && per_page.present? ? start + per_page - 1 : -1

        ids = Hari.redis.zrevrange(key, start, stop)
        property.entity.find *ids
      end

      private

      def key
        "#{property.entity.node_type}|#{property.name}:#{digest(value)}"
      end

      def digest(value)
        Digest::MD5.hexdigest value
      end

    end
  end
end
