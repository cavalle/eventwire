require 'unit/drivers/drivers_helper'

unless ENV['TRAVIS']

  describe Eventwire::Drivers::Zero do
    it_should_behave_like 'a driver with single-process support'
  end

end