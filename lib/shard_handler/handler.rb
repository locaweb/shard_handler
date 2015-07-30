module ShardHandler
  # Handles which {ConnectionHandler} instance should be used based on the
  # shard name that is set for the Thread. Each {Model} class has its own
  # {Handler}.
  #
  # @see Model
  # @api private
  class Handler
    # @param klass [ActiveRecord::Base] model class
    # @param configs [Hash] a hash with database connection settings
    def initialize(klass, configs)
      @klass = klass
      @configs = configs
      @cache = {}
    end

    # Creates a {ConnectionHandler} instance for each configured shard and puts
    # it on cache to be used later by {#connection_handler_for}.
    def setup
      resolver = ActiveRecord::ConnectionAdapters::ConnectionSpecification::Resolver.new(@configs)

      @configs.each do |name, _|
        name = name.to_sym

        connection_handler = ActiveRecord::ConnectionAdapters::ConnectionHandler.new
        connection_handler.establish_connection(@klass, resolver.spec(name))

        @cache[name] = connection_handler
      end
    end

    # Returns the appropriate ConnectionHandler instance for the given shard
    # name.
    #
    # @param name [Symbol, String] shard name
    # @return [ActiveRecord::ConnectionAdapters::ConnectionHandler]
    def connection_handler_for(name)
      @cache.fetch(name.to_sym) do
        fail UnknownShardError, "#{name.inspect} is not a valid shard name"
      end
    end

    # Disconnects from all shards.
    def disconnect_all
      @cache.values.map(&:clear_all_connections!)
    end
  end
end
