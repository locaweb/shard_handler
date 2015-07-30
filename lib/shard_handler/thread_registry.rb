require 'active_support/per_thread_registry'

module ShardHandler
  # This class is used as a registry for the shard name that is being used in
  # the current thread. Because ActiveRecord's connections are global in the
  # thread scope, we need to make sure that the shard name is changed only for
  # the current thread and not on process or other threads.
  #
  # @see ActiveSupport::PerThreadRegistry
  # @api private
  class ThreadRegistry
    extend ActiveSupport::PerThreadRegistry
    attr_accessor :current_shard
  end
end
