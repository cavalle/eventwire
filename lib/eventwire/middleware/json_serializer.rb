require 'json'

module Eventwire
  module Middleware
    class JSONSerializer < Base
      def subscribe(event_name, handler_id, &handler)
        @app.subscribe event_name, handler_id do |data|
          handler.call parse_json(data)
        end
      end
      
      def publish(event_name, event_data)
        @app.publish event_name, event_data.to_json
      end
      
      private
      
      def parse_json(json)
        json != 'null' ? JSON.parse(json) : nil
      end
    end
  end
end