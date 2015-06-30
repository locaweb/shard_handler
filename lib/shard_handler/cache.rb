module ShardHandler
  class Cache
    def initialize(configs)
      @cache = {}
      @configs = configs
    end

    def cache_connection_handlers
      resolver = resolver_class.new(@configs)

      @configs.each do |name, _|
        name = name.to_sym

        handler = connection_handler_class.new
        handler.establish_connection(Model, resolver.spec(name))

        @cache[name] = handler
      end
    end

    def connection_handler_for(name)
      @cache[name.to_sym] if name
    end

    protected

    def resolver_class
      ActiveRecord::ConnectionAdapters::ConnectionSpecification::Resolver
    end

    def connection_handler_class
      ActiveRecord::ConnectionAdapters::ConnectionHandler
    end
  end
end
