module Hari
  module Configuration
    module Redis

      def redis
        @redis || begin
          self.redis = 'localhost:6379'
          @redis
        end
      end

      def redis=(server)
        @redis = redis_namespace(server)
      end

      def disable_redis_namespace!
        @redis_namespace_disabled = true
      end

      def redis_namespace_disabled?
        @redis_namespace_disabled
      end

      private

      def redis_namespace(server)
        return redis_server(server) if redis_namespace_disabled?

        prefix = 'hari'

        if server.kind_of?(::Redis::Namespace)
          prefix = "#{server.namespace}:#{prefix}"
        end

        ::Redis::Namespace.new prefix, redis: redis_server(server)
      end

      def redis_server(server)
        case server
        when String
          host, port = server.split(':')
          ::Redis.new host: host, port: port
        when Hash
          ::Redis.new server
        else
          server
        end
      end

    end
  end
end
