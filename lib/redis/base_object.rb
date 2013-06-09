require 'connection_pool'

class Redis
  class ConnectionPoolProxy
    attr_accessor :redis, :use_connection_pool
    def initialize(redis, use_connection_pool)
      @use_connection_pool = use_connection_pool
      setup_redis_connection(redis)
    end

    def rcmd(command, *args)
      if use_connection_pool
        redis.with do |conn|
          conn.public_send(command, *args)
        end
      else
        redis.public_send(command, *args)
      end
    end

    private

    def setup_redis_connection(redis)
      if use_connection_pool
        @redis = ConnectionPool.new(:size => 5, :timeout => 5) { redis }
      else
        @redis = redis
      end
    end
  end
end

class Redis
  # Defines base functionality for all redis-objects.
  class BaseObject
    def initialize(key, *args)
      @key     = key.is_a?(Array) ? key.flatten.join(':') : key
      @options = args.last.is_a?(Hash) ? args.pop : {}
      @myredis = args.first
    end

    # Dynamically query the handle to enable resetting midstream
    def redis
      @myredis || ::Redis::Objects.redis
    end

    def redis_proxy
      @proxy ||= ConnectionPoolProxy.new(redis, true)
    end

    alias :inspect :to_s  # Ruby 1.9.2
  end
end

