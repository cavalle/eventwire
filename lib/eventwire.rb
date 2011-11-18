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
      @namespace = nil
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
    
    def namespace
      @namespace
    end
    
    def namespace=(namespace)
      @namespace = namespace
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
    end
    
    def subscribe(event_name, handler_id, &handler)
      driver.subscribe event_name, handler_id, &handler
    end

    def middleware
      @middleware ||= [ [Eventwire::Middleware::ErrorHandler, {:error_handler => Eventwire.error_handler, :logger => Eventwire.logger}],
                        [Eventwire::Middleware::Logger, {:logger => Eventwire.logger}],
                         Eventwire::Middleware::JSONSerializer,
                         Eventwire::Middleware::DataObjects ]
    end
    
    def decorate(driver)
      middleware.inject(driver) do |driver, args|
        args = Array(args)
        klass = args.shift
        if args && args.any?
          klass.new(driver, *args)
        else
          klass.new(driver)
        end
      end
    end

  end
  
end
