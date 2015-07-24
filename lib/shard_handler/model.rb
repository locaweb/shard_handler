require 'active_record'

module ShardHandler
  class Model < ActiveRecord::Base
    self.abstract_class = true

    class << self
      def current_shard
        ThreadRegistry.current_shard
      end

      def current_shard=(name)
        ThreadRegistry.current_shard = name.nil? ? nil : name.to_sym
      end

      def connection_handler
        ShardHandler.current_connection_handler || super
      end

      private :establish_connection
    end
  end
end
