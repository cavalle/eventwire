# encoding: UTF-8
require 'spec_helper'

describe Eventwire::Configuration do
  describe 'defaults' do
    subject { Eventwire::Configuration.new }

    it 'driver is InProcess' do
      subject.driver.should be_an_instance_of(Eventwire::Drivers::InProcess)
    end

    it 'logger is a Logger' do
      subject.logger.should be_an_instance_of(Logger)
    end

    it 'namespace is nil' do
      subject.namespace.should be_nil
    end
  end

  describe 'override' do
    subject { Eventwire::Configuration.new }

    it 'driver can be changed to other driver given a class of it' do
      driver = Object.new

      subject.driver = driver

      subject.driver.should == driver
    end

    it 'driver can be changed to other driver given its name' do
      Eventwire::Drivers::AwesomeDriver = Class.new

      subject.driver = :AwesomeDriver

      subject.driver.should be_an_instance_of(Eventwire::Drivers::AwesomeDriver)
    end
  end

end