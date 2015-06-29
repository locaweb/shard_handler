require 'active_record'

module ShardHandler
  class Model < ActiveRecord::Base
    self.abstract_class = true

    class << self
      def connection_handler
        return super unless ShardHandler.current_shard

        ShardHandler::Cache.connection_handlers[ShardHandler.current_shard] ||
          raise(InvalidShardName)
      end

      private :establish_connection
    end
  end
end
