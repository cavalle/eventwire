module Eventwire
  module Subscriber
    def self.included(base)
      base.extend DSL
    end
    
    module DSL
      def on(event_name, &handler)
        Eventwire.subscribe event_name, &handler
      end
    end
  end
end