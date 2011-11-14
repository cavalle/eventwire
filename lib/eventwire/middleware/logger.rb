module Eventwire
  module Middleware
    class Logger < Base

      def initialize(app, options = {})
        super(app)
        @logger = options.delete(:logger) || ::Logger.new(nil)
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

      private
      def logger
        @logger
      end
      
    end
  end
end