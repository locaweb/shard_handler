require 'shard_handler/version'
require 'shard_handler/model'
require 'shard_handler/cache'

module ShardHandler
  class InvalidShardName < StandardError; end

  class << self
    def setup(shards_config)
      Cache.connection_handlers = {}

      shards_names = shards_config.keys.map(&:to_sym)
      shards_names.each do |name|
        cache_connection_handler(name, shards_config)
      end
    end

    protected

    def cache_connection_handler(shard_name, configs)
      spec = resolver_class.new(configs).spec(shard_name)

      handler = connection_handler_class.new
      handler.establish_connection(Model, spec)

      Cache.connection_handlers[shard_name] = handler
    end

    def resolver_class
      ActiveRecord::ConnectionAdapters::ConnectionSpecification::Resolver
    end

    def connection_handler_class
      ActiveRecord::ConnectionAdapters::ConnectionHandler
    end
  end
end
