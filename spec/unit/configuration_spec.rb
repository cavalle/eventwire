require 'spec_helper'

describe 'Eventwire configuration' do
  describe 'driver' do
    before do
      Eventwire.middleware.clear
    end
    
    it 'is InProcess by default' do
      Eventwire.driver.should be_an_instance_of(Eventwire::Drivers::InProcess)
    end
    
    it 'can be changed to other driver given an instance of it' do
      driver = Object.new
      
      Eventwire.driver = driver
      
      Eventwire.driver.should == driver
    end
    
    it 'can be changed to other driver given its name' do
      Eventwire::Drivers::AwesomeDriver = Class.new
      
      Eventwire.driver = :AwesomeDriver
      
      Eventwire.driver.should be_an_instance_of(Eventwire::Drivers::AwesomeDriver)
    end
    
    context 'driver decoration' do
      
      it 'decorates the driver with one middleware' do
        middleware = Struct.new(:app)
        driver = Object.new
        
        Eventwire.middleware.replace [middleware]
        Eventwire.driver = driver
        
        Eventwire.driver.should be_an_instance_of(middleware)
        Eventwire.driver.app.should be(driver)
      end

      it 'decorates the driver with more than one middlewares' do
        middleware1 = Struct.new(:app)
        middleware2 = Struct.new(:app)
        driver = Object.new
        
        Eventwire.middleware.replace [middleware1, middleware2]
        Eventwire.driver = driver
        
        Eventwire.driver.should be_an_instance_of(middleware2)
        Eventwire.driver.app.should be_an_instance_of(middleware1)
        Eventwire.driver.app.app.should be(driver)
      end
    end
  end  
end