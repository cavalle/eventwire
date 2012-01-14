module Eventwire
  module Middleware
    class Logger < Base
      def initialize(app, config)
        super(app)
        @config = config
      end
      
      def subscribe(event_name, handler_id, &handler)
        @app.subscribe event_name, handler_id do |data|
          begin
            logger.info "Starting to process `#{event_name}` with handler `#{handler_id}` and data `#{data.inspect}`"
            handler.call data
          ensure
            logger.info "End processing `#{event_name}`"
          end
        end
      end
      
      def publish(event_name, event_data = nil)
        @app.publish event_name, event_data
        logger.info "Event published `#{event_name}` with data `#{event_data.inspect}`"
      end
     
      private

      def logger
        @config.logger
      end   
    end
  end
end
