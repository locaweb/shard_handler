require 'active_support/per_thread_registry'

module ShardHandler
  class ThreadRegistry
    extend ActiveSupport::PerThreadRegistry
    attr_accessor :current_shard
  end
end
