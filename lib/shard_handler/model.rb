require 'active_record'

module ShardHandler
  class Model < ActiveRecord::Base
    self.abstract_class = true

    class << self
      def handler
        @@handler
      end

      def setup(config)
        @@handler = Handler.new(self, config)
        @@handler.setup
      end

      def current_shard
        ThreadRegistry.current_shard
      end

      def current_shard=(name)
        ThreadRegistry.current_shard = name.nil? ? nil : name.to_sym
      end

      def connection_handler
        @@handler.connection_handler_for(current_shard) || super
      end

      def using(shard, &_block)
        old_shard = current_shard
        self.current_shard = shard
        yield
      ensure
        self.current_shard = old_shard
      end

      private :establish_connection
    end
  end
end
