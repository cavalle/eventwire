require 'unit/drivers/drivers_helper'

describe Eventwire::Drivers::AMQP do
  
  it_should_behave_like 'a driver'
  it_should_behave_like 'a driver with multiprocess support'
  
end