module Hari
  module Keys
    class Key

      attr_reader :node, :name, :options

      def initialize(node = nil, options = {})
        @node, @options = node, options
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

      def serialize(value)
        type = options[:type]

        if type.nil? || value.nil?
          value
        else
          value.kind_of?(Enumerable) ? value.map(&:to_json) : value.to_json
        end
      end

      def desserialize(value)
        type = options[:type]

        if type.nil? || value.nil?
          value
        else
          value.kind_of?(Enumerable) ? value.map { |v| type.from_json(v) }
                                     : type.from_json(value)
        end
      end

    end
  end
end
