module Eventwire
  module Middleware
    class Logger < Base  
      
      def subscribe(event_name, handler_id, &handler)
        @app.subscribe event_name, handler_id do |data|
          begin
            Eventwire.logger.info "Starting to process `#{event_name}` with handler `#{handler_id}` and data `#{data.inspect}`"
            handler.call data
          ensure
            Eventwire.logger.info "End processing `#{event_name}`"
          end
        end
      end
      
    end
  end
end