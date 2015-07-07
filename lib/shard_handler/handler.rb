module ShardHandler
  class Handler
    attr_reader :cache

    def initialize(configs)
      @cache = {}
      @configs = configs
    end

    def cache_connection_handlers
      resolver = ActiveRecord::ConnectionAdapters::ConnectionSpecification::Resolver.new(@configs)

      @configs.each do |name, _|
        name = name.to_sym

        connection_handler = ActiveRecord::ConnectionAdapters::ConnectionHandler.new
        connection_handler.establish_connection(Model, resolver.spec(name))

        @cache[name] = connection_handler
      end
    end

    def connection_handler_for(name)
      @cache[name.to_sym] if name
    end

    def disconnect_all
      @cache.values.map(&:clear_all_connections!)
    end
  end
end
