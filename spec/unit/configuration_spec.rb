# encoding: UTF-8
require 'spec_helper'

describe Eventwire::Configuration do
  describe 'driver' do
    context 'without middleware' do
      before do
        subject.middleware.clear
      end

      it 'returns a AMQP adapter if none is set' do
        subject.driver.should be_instance_of(Eventwire::Adapters::AMQP)
      end

      it 'returns the adapter if one is set' do
        adapter = Object.new
        subject.adapter = adapter
        subject.driver.should == adapter
      end

      it 'returns an instance of the adapter if its name is set' do
        Eventwire::Adapters::AwesomeAdapter = Class.new
        subject.adapter = :AwesomeAdapter
        subject.driver.should be_an_instance_of(Eventwire::Adapters::AwesomeAdapter)
      end
    end

    context 'with middleware' do
      it 'builds a driver decorating the adapter with one middleware' do
        adapter = Object.new
        middleware = Struct.new(:app)

        subject.adapter = adapter
        subject.middleware.replace [middleware]

        subject.driver.should be_instance_of(middleware)
        subject.driver.app.should == adapter
      end

      it 'builds a driver decorating the adapter with one middleware with options' do
        middleware = Struct.new(:app, :options)
        options = {}

        subject.middleware.replace [[middleware, options]]

        subject.driver.options.should == options
      end

      it 'builds a driver decorating the adapter with more than one middlewares' do
        adapter = Object.new
        middleware1 = Struct.new(:app)
        middleware2 = Struct.new(:app)

        subject.adapter = adapter
        subject.middleware.replace [middleware1, middleware2]

        subject.driver.should be_instance_of(middleware2)
        subject.driver.app.should be_instance_of(middleware1)
        subject.driver.app.app.should == adapter
      end
    end
  end

  describe 'middleware' do
    it 'contains ErrorHandler by default' do
      subject.middleware.should include([Eventwire::Middleware::ErrorHandler, subject])
    end

    it 'contains Logger by default' do
      subject.middleware.should include([Eventwire::Middleware::Logger, subject])
    end

    it 'contains JSONSerializer by default' do
      subject.middleware.should include(Eventwire::Middleware::JSONSerializer)
    end

    it 'contains DataObjects after Serializer by default' do
      subject.middleware.should include(Eventwire::Middleware::DataObjects)
      subject.middleware.index(Eventwire::Middleware::DataObjects).should be >
        subject.middleware.index(Eventwire::Middleware::JSONSerializer)
    end
  end

  describe 'logger' do
    it 'returns a stdout logger by default' do
      with_stdout(StringIO.new) do |io|
        subject.logger.error 'hello'
        io.string.should == "hello\n"
      end
    end

    it 'returns a specified logger' do
      logger = Object.new
      subject.logger = logger
      subject.logger.should == logger
    end

    it 'is used in the default logger middleware' do
      logger = Object.new
      subject.logger = logger
    end
  end

  describe 'namespace' do
    it 'is not set by default' do
      subject.namespace.should be_blank
    end

    it 'returns a specified logger' do
      subject.namespace = 'MyAppName'
      subject.namespace.should == 'MyAppName'
    end
  end

  describe 'error_handler' do
    it 'returns a trivial lambda' do
      subject.error_handler.should be_instance_of(Proc)
    end

    it 'returns a specified lambda' do
      handler = lambda {|ex|}
      subject.on_error &handler
      subject.error_handler.should == handler
    end
  end

  describe 'test_mode' do
    it 'returns false by default' do
      subject.test_mode.should be_false
    end
  end
end
