require 'eventwire/version'
require 'eventwire/publisher'
require 'eventwire/subscriber'
require 'eventwire/drivers'

module Eventwire
  
  def self.publish(event_name, event_data = nil)
    driver.publish event_name, event_data
  end
  
  def self.subscribe(event_name, &handler)
    driver.subscribe event_name do |data|
      handler.call build_event(data)
    end
  end
  
  def self.build_event(data)
    data && Struct.new(*data.keys).new(*data.values)
  end
  
  def self.driver
    @driver ||= Drivers::InProcess.new
  end
  
end
