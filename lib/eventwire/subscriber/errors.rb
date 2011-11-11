module Eventwire
  module Subscriber
    class Errors
      def initialize(handler, event_name, handler_id)
        @handler = handler
      end
      
      def call(data)
        begin
          @handler.call(data)
        rescue Exception => ex
          Eventwire.logger.error "\nAn error occurred: `#{ex.message}`\n#{ex.backtrace.join("\n")}\n"
          Eventwire.error_handler.call(ex)
        end
      end
    end
  end
end