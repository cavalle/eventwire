require 'msgpack'

# TODO: Add support for Time
module Eventwire
  module Middleware
    class MessagePackSerializer < Base
      def subscribe(event_name, handler_id, &handler)
        @app.subscribe event_name, handler_id do |data|
          handler.call MessagePack.unpack(data)
        end
      end
      
      def publish(event_name, event_data)
        @app.publish event_name, event_data.to_msgpack
      end
    end
  end
end