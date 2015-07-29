require 'active_record'

module ShardHandler
  class Model < ActiveRecord::Base
    self.abstract_class = true

    class << self
      # @api private
      # @return [Handler]
      def handler
        @@handler
      end

      # This method creates an instance of {Handler} for this class. This method
      # must be called before performing any query on shards.
      #
      # @param config [Hash] a hash with database connection settings
      def setup(config)
        @@handler = Handler.new(self, config)
        @@handler.setup
      end

      # Returns the current shard name for the current Thread.
      #
      # @return [Symbol]
      def current_shard
        ThreadRegistry.current_shard
      end

      # Sets the current shard name for the current Thread.
      #
      # @param name [Symbol, String] shard name configured using {.setup}
      def current_shard=(name)
        ThreadRegistry.current_shard = name.nil? ? nil : name.to_sym
      end

      # Overrides ActiveRecord::Core#connection_handler method to return the
      # appropriate ConnectionHandler for the current shard. This is the
      # integration point between ActiveRecord and this gem.
      #
      # @api private
      # @return (see Handler#connection_handler_for)
      def connection_handler
        fail(SetupError, 'the model was not setup') unless @@handler
        @@handler.connection_handler_for(current_shard) || super
      end

      # This method will switch to the passed shard making all queries be
      # executed using the shard connection.
      #
      # @param shard [Symbol, String] shard name configured using .setup
      # @yield The block that must be executed using the shard connection
      def using(shard)
        old_shard = current_shard
        self.current_shard = shard
        yield
      ensure
        # Returns any connections in use by the current thread back to the pool.
        # It must be executed before changing the shard name back to its
        # old value.
        self.clear_active_connections!
        self.current_shard = old_shard
      end

      private :establish_connection
    end
  end
end
