require 'integration/drivers/drivers_helper'

describe_driver Eventwire::Drivers::InProcess do
  it_should_behave_like 'a driver with single-process support'
end