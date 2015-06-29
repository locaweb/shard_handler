require 'shard_handler/version'
require 'shard_handler/model'
require 'shard_handler/cache'

require 'active_support/per_thread_registry'

module ShardHandler
  class InvalidShardName < StandardError; end

  class RuntimeRegistry
    extend ActiveSupport::PerThreadRegistry
    attr_accessor :current_shard
  end

  class << self
    def current_shard
      RuntimeRegistry.current_shard
    end

    def current_shard=(name)
      RuntimeRegistry.current_shard = name.nil? ? nil : name.to_sym
    end

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
