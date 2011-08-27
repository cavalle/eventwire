require 'eventwire/version'
require 'eventwire/publisher'
require 'eventwire/subscriber'
require 'eventwire/drivers/in_process'

module Eventwire
  
  def self.publish(event_name, event_data = nil)
    driver.publish event_name, event_data
  end
  
  def self.subscribe(event_name, &handler)
    driver.subscribe event_name, &handler
  end
  
  def self.driver
    @driver ||= Drivers::InProcess.new
  end
  
end
