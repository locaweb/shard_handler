module ShardHandler
  # This error is raised when one tries to perform a query on {Model} without
  # setting it up first.
  class SetupError < StandardError; end

  # This error is raised when using a shard name that does not exist in the
  # configuration.
  class UnknownShardError < StandardError; end
end
