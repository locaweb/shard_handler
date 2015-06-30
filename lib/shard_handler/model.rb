require 'active_record'

module ShardHandler
  class Model < ActiveRecord::Base
    self.abstract_class = true

    class << self
      def connection_handler
        ShardHandler.current_connection_handler || super
      end

      private :establish_connection
    end
  end
end
