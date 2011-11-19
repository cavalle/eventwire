require 'eventwire/version'
require 'eventwire/configuration'
require 'eventwire/publisher'
require 'eventwire/subscriber'
require 'eventwire/drivers'
require 'eventwire/middleware'

module Eventwire
  
  class << self

    attr_writer :configuration

    def configure
      yield(configuration)
      configuration.decorate
    end

    def configuration
      @configuration ||= Configuration.new
    end

    def driver
      configuration.driver
    end
    
    def logger
      configuration.logger
    end

    def namespace
      configuration.namespace
    end

    def middleware
      configuration.middleware
    end

    def error_handler
      configuration.on_error
    end
  
    def start_worker
      driver.start
    end
  
    def stop_worker
      driver.stop
    end

    def publish(event_name, event_data = nil)
      driver.publish event_name, event_data
    end
    
    def subscribe(event_name, handler_id, &handler)
      driver.subscribe event_name, handler_id, &handler
    end

    def reset!
      @configuration = nil
    end

  end
  
end
