require 'eventwire/version'
require 'eventwire/publisher'
require 'eventwire/subscriber'
require 'eventwire/drivers'

module Eventwire
  
  def self.publish(event_name, event_data = nil)
    driver.publish event_name, event_data
    logger.info "Event published `#{event_name}` with data `#{event_data.inspect}`"
  end
  
  def self.subscribe(event_name, handler_id, &handler)
    driver.subscribe event_name, handler_id do |data|
      begin
        logger.info "Starting to process `#{event_name}` with handler `#{handler_id}` and data `#{data.inspect}`"
        handler.call build_event(data) 
        logger.info "End processing `task_completed`"
      rescue Exception => ex
        @error_handler.call(ex) if @error_handler
      end
    end
  end
  
  def self.build_event(data)
    data && Struct.new(*data.keys.map(&:to_sym)).new(*data.values)
  end
  
  def self.driver
    @driver ||= Drivers::InProcess.new
  end
  
  def self.driver=(driver)
    klass = Drivers.const_get(driver.to_sym) if driver.respond_to?(:to_sym)
    @driver = klass ? klass.new : driver
  end
  
  def self.logger=(logger)
    @logger = logger
  end
  
  def self.logger
    @logger ||= Logger.new(nil)
  end
  
  def self.start_worker
    driver.start
  end
  
  def self.stop_worker
    driver.stop
  end
  
  def self.on_error(&block)
    @error_handler = block
  end
  
end
