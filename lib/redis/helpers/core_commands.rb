class Redis
  module Helpers
    # These are core commands that all types share (rename, etc)
    module CoreCommands
      def exists?
        redis_proxy.rcmd(:exists, key)
      end

      def delete
        redis_proxy.rcmd(:del, key)
      end
      alias_method :del, :delete
      alias_method :clear, :delete

      def type
        redis_proxy.rcmd(:type, key)
      end

      def rename(name, setkey=true)
        dest = name.is_a?(self.class) ? name.key : name
        ret  = redis_proxy.rcmd(:rename, key, dest)
        @key = dest if ret && setkey
        ret
      end

      def renamenx(name, setkey=true)
        dest = name.is_a?(self.class) ? name.key : name
        ret  = redis_proxy.rcmd(:renamenx, key, dest)
        @key = dest if ret && setkey
        ret
      end

      def expire(seconds)
        redis_proxy.rcmd(:expire, key, seconds)
      end

      def expireat(unixtime)
        redis_proxy.rcmd(:expireat, key, unixtime)
      end

      def persist
        redis_proxy.rcmd(:persist, key)
      end

      def ttl
        redis_proxy.rcmd(:ttl, @key)
      end

      def move(dbindex)
        redis_proxy.rcmd(:move, key, dbindex)
      end

      def sort(options={})
        options[:order] = "asc alpha" if options.keys.count == 0  # compat with Ruby
        redis_proxy.rcmd(:sort, key, options)
      end
    end

  end
end
