# encoding: UTF-8
require 'spec_helper'

describe Eventwire::Publisher do
  
  describe '#publish_event' do
    
    before do
      @driver = mock
      Eventwire.configuration.stub(:driver => @driver)
    end
    
    subject { class_including(Eventwire::Publisher).new }
    
    it 'should publish the event using the current adapter' do
      @driver.should_receive(:publish).with(:task_created, anything)
      
      subject.publish_event :task_created
    end
    
    it 'should publish the event using a symbol as event name' do
      @driver.should_receive(:publish).with(:task_created, anything)
      
      subject.publish_event 'task_created'
    end
    
    it 'should publish the event with its data using the current adapter' do
      @driver.should_receive(:publish).with(:task_created, {:task_name => 'Cleaning'})

      subject.publish_event :task_created, :task_name => 'Cleaning'
    end
    
  end
  
end
