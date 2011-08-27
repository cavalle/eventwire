require 'spec_helper'

describe Eventwire::Subscriber do
  
  describe '#on' do
    
    subject { class_including Eventwire::Subscriber }
    
    it 'should subscribe to the event using the current driver' do
      Eventwire.driver.should_receive(:subscribe).with(:task_completed)
      
      subject.on(:task_completed) { } 
    end
    
    it 'should subscribe with a handler that builds an event object' do
      Eventwire.driver.should_receive(:subscribe) do |event_name, &handler|
        handler.call(:task_name => 'Cleaning').should == 'Cleaning'
      end
      
      subject.on(:task_completed) { |data| data.task_name }
    end
    
  end
  
end