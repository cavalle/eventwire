# encoding: UTF-8
require 'spec_helper'

describe Eventwire::Subscriber do
  
  describe '#on' do
    
    before do
      @driver = mock
      Eventwire.configuration.stub(:driver => @driver)
      Eventwire.configuration.logger = Logger.new(nil)
    end
    
    subject { class_including Eventwire::Subscriber }

    it 'should subscribe to the event using the current driver' do
      Eventwire.driver.should_receive(:subscribe?).with(any_args).and_return(false)
      Eventwire.driver.should_receive(:subscribe).with(:task_completed, anything)
      
      subject.on(:task_completed) { } 
    end

    it 'should always subscribe using a symbol as the event name' do
      Eventwire.driver.should_receive(:subscribe?).with(any_args).and_return(false)
      Eventwire.driver.should_receive(:subscribe).with(:task_completed, anything)
      
      subject.on('task_completed') { } 
    end
    
    it 'should include the event name in the handler id' do
      @driver.should_receive(:subscribe?).with(any_args).and_return(false)
      @driver.should_receive(:subscribe).with do |event_name, handler_id|
        handler_id =~ /task_completed/
      end
      
      subject.on(:task_completed) { }
    end
    
    it 'should include the class name in the handler id' do
      ThisModule = Module.new
      ThisModule::ThisSubscriber = subject
      
      @driver.should_receive(:subscribe?).with(any_args).and_return(false)
      @driver.should_receive(:subscribe).with do |event_name, handler_id|
        handler_id =~ /ThisModule::ThisSubscriber/
      end
      
      subject.on(:task_completed) { }
      
      ThisModule.parent.send :remove_const, :ThisModule
    end

    it 'should raise a exception if try to associate more than one handler per class' do
      @driver.should_receive(:subscribe?).and_return(false,true)
      @driver.should_receive(:subscribe).with(any_args)
      subject.on(:task_completed) { } 

      expect {subject.on(:task_completed) { } }.to raise_error(Eventwire::Error, 'Multiple handlers for same event in same class')
    end

    it 'should prepend a namespace to to handler id' do
      Eventwire.configuration.namespace = 'MyApplication'
      
      @driver.should_receive(:subscribe?).with(any_args).and_return(false)
      @driver.should_receive(:subscribe).with do |event_name, handler_id|
        handler_id =~ /MyApplication/
      end

      subject.on(:task_completed) { }
    end
    
    it 'should warn if no namespace has been specified' do
      io = StringIO.new
      Eventwire.configuration.logger = Logger.new(io)

      @driver.stub(:subscribe)
      @driver.stub(:subscribe?)
      
      subject.on(:task_completed) { }
      
      io.string.should =~ /Eventwire.namespace/
    end
    
    it 'should not warn if namespace has been specified' do
      io = StringIO.new
      Eventwire.configuration.logger = Logger.new(io)
      Eventwire.configuration.namespace = 'MyApplication'
      
      @driver.stub(:subscribe)
      @driver.stub(:subscribe?)
      
      subject.on(:task_completed) { }
      
      io.string.should be_blank
    end

    it 'should subscribe to multiple events' do
      Eventwire.driver.should_receive(:subscribe?).with(any_args).and_return(false,false)
      Eventwire.driver.should_receive(:subscribe).with(:task_completed, anything)
      Eventwire.driver.should_receive(:subscribe).with(:project_completed, anything)

      subject.on(:task_completed, :project_completed) { }
    end
  end
  
end
