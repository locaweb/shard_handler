require 'active_record'

module ShardHandler
  class Model < ActiveRecord::Base
    self.abstract_class = true

    class << self
      def current_shard_name
        Thread.current[:current_shard_name]
      end

      def connection_handler
        return super if current_shard_name.blank?
        ShardHandler::Cache.connection_handlers[current_shard_name] ||
          raise(InvalidShardName)
      end

      private :establish_connection
    end
  end
end
