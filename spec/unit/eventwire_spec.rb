# encoding: UTF-8
require 'spec_helper'

describe Eventwire do

  describe '#configure' do
    it 'decorates the driver with one middleware' do
      middleware = Struct.new(:app)
      driver = Object.new

      Eventwire.middleware.replace [middleware]
      Eventwire.configure do |config|
        config.driver = driver
      end

      Eventwire.driver.should be_an_instance_of(middleware)
      Eventwire.driver.app.should be(driver)
    end

    it 'decorates the driver with one middleware and its options' do
      middleware = Struct.new(:app, :options)
      driver = Object.new
      options = {:logger => Logger.new(nil)}

      Eventwire.middleware.replace [[middleware, options]]
      Eventwire.configure do |config|
        config.driver = driver
      end

      Eventwire.driver.should be_an_instance_of(middleware)
      Eventwire.driver.app.should be(driver)
      Eventwire.driver.options.should be(options)
    end

    it 'decorates the driver with more than one middlewares' do
      middleware1 = Struct.new(:app)
      middleware2 = Struct.new(:app)
      driver = Object.new

      Eventwire.middleware.replace [middleware1, middleware2]
      Eventwire.configure do |config|
        config.driver = driver
      end

      Eventwire.driver.should be_an_instance_of(middleware2)
      Eventwire.driver.app.should be_an_instance_of(middleware1)
      Eventwire.driver.app.app.should be(driver)
    end
  end
end