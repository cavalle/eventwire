module Eventwire
  module Middleware
    class DataObjects < Base
      def subscribe(event_name, handler_id, &handler)
        @app.subscribe event_name, handler_id do |data|
          handler.call build_event(data)
        end
      end

      private

      def build_event(data)
        data && Struct.new(*data.keys.map(&:to_sym)).new(*data.values)
      end
    end
  end
end