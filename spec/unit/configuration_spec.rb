require 'spec_helper'

describe 'Eventwire configuration' do
  describe 'driver' do
    it 'is InProcess by default' do
      Eventwire.driver.should be_an_instance_of(Eventwire::Drivers::InProcess)
    end
    
    it 'can be changed to other driver given an instance of it' do
      driver = Eventwire::Drivers::Redis.new
      Eventwire.driver = driver
      Eventwire.driver.should == driver
    end
    
    it 'can be changed to other driver given its name' do
      Eventwire.driver = :Redis
      Eventwire.driver.should be_an_instance_of(Eventwire::Drivers::Redis)
    end
  end
end