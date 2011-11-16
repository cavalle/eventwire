require 'bson'

module Eventwire
  module Middleware
    class BSONSerializer < Base
      def subscribe(event_name, handler_id, &handler)
        @app.subscribe event_name, handler_id do |data|
          handler.call BSON.deserialize(data)
        end
      end
      
      def publish(event_name, event_data)
        @app.publish event_name, BSON.serialize(event_data)
      end
    end
  end
end