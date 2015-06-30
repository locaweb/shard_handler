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
    def setup(shards_config)
      @cache = Cache.new(shards_config)
      @cache.cache_connection_handlers
    end

    def current_shard
      RuntimeRegistry.current_shard
    end

    def current_shard=(name)
      RuntimeRegistry.current_shard = name.nil? ? nil : name.to_sym
    end

    def current_connection_handler
      @cache.connection_handler_for(current_shard)
    end
  end
end
