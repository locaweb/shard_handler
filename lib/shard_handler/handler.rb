module ShardHandler
  class Handler
    def initialize(klass, configs)
      @klass = klass
      @configs = configs
      @cache = {}
    end

    def setup
      resolver = ActiveRecord::ConnectionAdapters::ConnectionSpecification::Resolver.new(@configs)

      @configs.each do |name, _|
        name = name.to_sym

        connection_handler = ActiveRecord::ConnectionAdapters::ConnectionHandler.new
        connection_handler.establish_connection(@klass, resolver.spec(name))

        @cache[name] = connection_handler
      end
    end

    def connection_handler_for(name)
      return if name.nil?
      @cache.fetch(name.to_sym) do
        fail UnknownShardError, "#{name.inspect} is not a valid shard name"
      end
    end

    def disconnect_all
      @cache.values.map(&:clear_all_connections!)
    end
  end
end
