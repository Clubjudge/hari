module Hari
  module Keys
    class Key

      attr_reader :node, :name

      def initialize(node = nil)
        @node = node
      end

      def key
        @key ||= begin
          prefix = node ? "#{Hari.node_key(node)}:" : ''
          prefix + name.to_s
        end
      end

      def delete!
        Hari.redis.del key
      end

      def exists?
        Hari.redis.exists key
      end

      def expire(milliseconds)
        Hari.redis.pexpire key, milliseconds
      end

      def expire_at(timestamp)
        Hari.redis.expireat key, ::Time.parse(timestamp).to_s
      end

      def persist
        Hari.redis.persist key
      end

      def type
        Hari.redis.type key
      end

      def ttl
        Hari.redis.ttl key
      end

    end
  end
end
