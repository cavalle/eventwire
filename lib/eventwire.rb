require 'eventwire/version'
require 'eventwire/publisher'
require 'eventwire/subscriber'
require 'eventwire/drivers'
require 'eventwire/middleware'

module Eventwire
  
  class << self
    
    def reset!
      @driver = nil
      @middleware = nil
      @logger = nil
    end
    
    def driver
      @driver ||= decorate(Drivers::InProcess.new)
    end
  
    def driver=(driver)
      klass = Drivers.const_get(driver.to_sym) if driver.respond_to?(:to_sym)
      @driver = decorate(klass ? klass.new : driver)
    end
    
    def logger
      @logger ||= Logger.new(nil)
    end
  
    def logger=(logger)
      @logger = logger
    end
  
    def start_worker
      driver.start
    end
  
    def stop_worker
      driver.stop
    end
  
    def on_error(&block)
      @error_handler = block
    end
    
    def error_handler
      @error_handler ||= lambda {|ex|}
    end
  
    def publish(event_name, event_data = nil)
      driver.publish event_name, event_data
      logger.info "Event published `#{event_name}` with data `#{event_data.inspect}`"
    end
    
    def subscribe(event_name, handler_id, &handler)
      Eventwire.driver.subscribe event_name, handler_id, &handler
    end
    
    class Middleware
      def initialize(app)
        @app = app
      end
      
      def method_missing(meth, *args, &blk)
        @app.send(meth, *args, &blk)
      end
    end
    
    def middleware
      @middleware ||= [ Eventwire::Middleware::ErrorHandler, 
                        Eventwire::Middleware::Logger, 
                        Eventwire::Middleware::DataObjects ]
    end
    
    def decorate(driver)
      middleware.inject(driver) do |driver, klass|
        klass.new(driver)
      end
    end

  end
  
end
