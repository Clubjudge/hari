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

      private

      def redis_namespace(server)
        prefix = 'hari'

        if server.kind_of?(::Redis::Namespace)
          prefix = "#{server.namespace}:#{prefix}"
        end

        ::Redis::Namespace.new prefix, redis_server(server)
      end

      def redis_server(server)
        return server unless server.kind_of?(::String)

        host, port = server.split(':')
        ::Redis.new host: host, port: port
      end

    end
  end
end
