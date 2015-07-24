require 'shard_handler/version'
require 'shard_handler/model'
require 'shard_handler/handler'

require 'active_support/per_thread_registry'

module ShardHandler
  class UnknownShardError < StandardError; end

  class RuntimeRegistry
    extend ActiveSupport::PerThreadRegistry
    attr_accessor :current_shard
  end

  class << self
    attr_reader :handler

    def setup(config)
      @handler = Handler.new(Model, config)
      @handler.setup
    end

    def current_shard
      RuntimeRegistry.current_shard
    end

    def current_shard=(name)
      RuntimeRegistry.current_shard = name.nil? ? nil : name.to_sym
    end

    def current_connection_handler
      @handler.connection_handler_for(current_shard)
    end

    def disconnect_all
      @handler.disconnect_all
    end

    def using(shard, &_block)
      old_shard = current_shard
      self.current_shard = shard
      yield
    ensure
      self.current_shard = old_shard
    end
  end
end
