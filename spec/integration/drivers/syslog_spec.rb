require 'integration/drivers/drivers_helper'

# Don't need root privilegies to run in test mode
Eventwire::Drivers::Syslog::DEFAULT_OPTIONS[:port] = 5514

describe Eventwire::Drivers::Syslog do
  it_should_behave_like 'a driver with single-process support'
end
