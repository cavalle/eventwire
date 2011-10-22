module Eventwire
  module Subscriber
    class Log
      def initialize(handler, event_name, handler_id)
        @handler = handler
        @event_name = event_name
        @handler_id = handler_id
      end
  
      def call(data)
        begin
          Eventwire.logger.info "Starting to process `#{@event_name}` with handler `#{@handler_id}` and data `#{data.inspect}`"
          @handler.call(data)
        ensure
          Eventwire.logger.info "End processing `#{@event_name}`"
        end
      end
    end
  end
end