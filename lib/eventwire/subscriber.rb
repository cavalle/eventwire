# encoding: UTF-8
module Eventwire
  module Subscriber
    def self.included(base)
      base.extend DSL
    end
    
    module DSL
      def on(*event_names, &handler)
        event_names.each do |event_name|
          unless Eventwire.subscribe?(event_name.to_sym, handler_id(event_name))
            Eventwire.subscribe event_name.to_sym, handler_id(event_name), &handler
          else
            raise Eventwire::Error, 'Multiple handlers for same event in same class'
          end
        end
      end
      
      private
      
      def handler_id(event_name)
        check_namespace!
        
        [namespace, event_name, self.name].compact.join('::')
      end
      
      def check_namespace!
        unless namespace
          Eventwire.logger.warn 'To avoid naming collisions between handlers in different applications, it’s strongly advised to set `Eventwire.namespace` to a unique identifier of your application'
        end
      end
      
      def namespace
        Eventwire.namespace
      end
      
    end
  end
end
