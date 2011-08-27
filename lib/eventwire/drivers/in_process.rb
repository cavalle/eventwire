module Eventwire
  module Drivers
    class InProcess
      def initialize
        @handlers = {}
      end
      
      def handlers(event_name)
        @handlers[event_name] ||= []
      end
      
      def publish(event_name, event_data = nil)
        handlers(event_name).each do |handler|
          handler.call event_data && Struct.new(*event_data.keys).new(*event_data.values)
        end
      end
      
      def subscribe(event_name, &handler)
        handlers(event_name) << handler
      end
    end
  end
end