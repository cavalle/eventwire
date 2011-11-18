# encoding: UTF-8
module Eventwire
  module Subscriber
    def self.included(base)
      base.extend DSL
    end
    
    module DSL
      def on(event_name, &handler)
        Eventwire.subscribe event_name, handler_id(event_name), &handler
      end
      
      private
      
      def handler_id(event_name)
        check_namespace!
        
        [namespace, event_name, self.name, increment_handler_counter].compact.join('::')
      end
      
      def check_namespace!
        unless namespace
          Eventwire.logger.warn 'To avoid naming collisions between handlers in different applications, it’s strongly advised to set `Eventwire.namespace` to a unique identifier of your application'
        end
      end
      
      def namespace
        Eventwire.namespace
      end
      
      def increment_handler_counter
        @_handler_counter ||= 0
        @_handler_counter +=  1
      end
    end
  end
end