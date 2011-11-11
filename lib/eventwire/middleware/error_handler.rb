module Eventwire
  module Middleware
    class ErrorHandler < Base
      def subscribe(event_name, handler_id, &handler)
        @app.subscribe event_name, handler_id do |data|
          begin
            handler.call(data)
          rescue Exception => ex
            Eventwire.logger.error "\nAn error occurred: `#{ex.message}`\n#{ex.backtrace.join("\n")}\n"
            Eventwire.error_handler.call(ex)
          end
        end
      end
    end
  end
end