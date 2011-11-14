module Eventwire
  module Middleware
    class ErrorHandler < Base

      def initialize(app, options = {})
        super(app)
        @error_handler = options.delete(:error_handler) || lambda{|ex|}
        @logger = options.delete(:logger) || Logger.new(nil)
      end

      def subscribe(event_name, handler_id, &handler)
        @app.subscribe event_name, handler_id do |data|
          begin
            handler.call(data)
          rescue Exception => ex
            logger.error "\nAn error occurred: `#{ex.message}`\n#{ex.backtrace.join("\n")}\n"
            error_handler.call(ex)
          end
        end
      end

      private
      def error_handler
        @error_handler
      end

      def logger
        @logger
      end
    end
  end
end