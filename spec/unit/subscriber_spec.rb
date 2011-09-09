require 'spec_helper'

describe Eventwire::Subscriber do
  
  describe '#on' do
    
    subject { class_including Eventwire::Subscriber }

    it 'should subscribe to the event using the current driver' do
      Eventwire.driver.should_receive(:subscribe).with(:task_completed, anything)
      
      subject.on(:task_completed) { } 
    end
    
    it 'should subscribe with a handler that builds an event object' do
      Eventwire.driver.should_receive(:subscribe) do |event_name, _, &handler|
        handler.call(:task_name => 'Cleaning').should == 'Cleaning'
      end
      
      subject.on(:task_completed) { |data| data.task_name }
    end
    
    it 'should subscribe to the event with incremental handler ids based on the class name' do
      ThisModule = Module.new
      ThisModule::ThisSubscriber = subject
      
      Eventwire.driver.should_receive(:subscribe).with(:task_completed, 'ThisModule::ThisSubscriber::1')
      Eventwire.driver.should_receive(:subscribe).with(:task_completed, 'ThisModule::ThisSubscriber::2')
      
      2.times do
        subject.on(:task_completed) { } 
      end
      
      ThisModule.parent.send :remove_const, :ThisModule
    end
    
  end
  
end