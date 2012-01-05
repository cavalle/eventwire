require 'integration/drivers/drivers_helper'

describe_driver Eventwire::Drivers::AMQP do
  it_should_behave_like 'a driver with single-process support'
  it_should_behave_like 'a driver with multi-process support'
end
