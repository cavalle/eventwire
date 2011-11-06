module Eventwire
  module Subscriber
    class Data
      def initialize(handler, event_name, handler_id)
        @handler = handler
      end
  
      def call(data)
        @handler.call(build_event(data))
      end
  
      private
  
      def build_event(data)
        data && Struct.new(*data.keys.map(&:to_sym)).new(*data.values)
      end
    end
  end
end