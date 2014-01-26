module Hari
  module Configuration
    #
    # Redis configuration module
    #
    module Redis

      # Returns redis client instance.
      # If not defined one, uses Redis default
      # configuration (localhost:6379)
      #
      # @return [Redis] redis client
      #
      def redis
        @redis || begin
          self.redis = 'localhost:6379'
          @redis
        end
      end

      # Sets redis client
      #
      # @return [Redis] redis client
      #
      def redis=(server)
        @redis = redis_namespace(server)
      end

      # By default Hari will namespace all keys
      # with the 'hari:' prefix. Calling this method,
      # this namespacing is disabled
      #
      # @return [true]
      #
      def disable_redis_namespace!
        @redis_namespace_disabled = true
      end

      # @return [true] if redis namespace is disabled
      # @return [false] if redis namespace is enabled
      #
      def redis_namespace_disabled?
        @redis_namespace_disabled
      end

      private

      # Namespaces the client with 'hari:' prefix,
      # unless redis namespace is disabled
      #
      # @param [String, Hash, Redis] redis client or configuration
      #
      # @return [Redis] redis client
      #
      def redis_namespace(server)
        return redis_server(server) if redis_namespace_disabled?

        ::Redis::Namespace.new 'hari', redis: redis_server(server)
      end

      # Mounts a redis server instance when configuration is passed
      #
      # @param [String, Hash, Redis] redis client or configuration
      #
      # @return [Redis] redis client
      #
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
