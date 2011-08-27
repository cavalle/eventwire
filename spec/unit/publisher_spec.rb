require 'spec_helper'

describe Eventwire::Publisher do
  
  let(:publisher)  { class_including(Eventwire::Publisher).new }
  let(:subscriber) { class_including(Eventwire::Subscriber) }
    
  describe '#publish_event' do
    
    it 'should run 1 event handler' do
      executed = false
      subscriber.on(:this_event) { executed = true }
      
      publisher.publish_event :this_event
      
      executed.should be_true
    end
    
    it 'should run more than 1 event handler for the event' do
      executed = [false, false]
      subscriber.on(:this_event) { executed[0] = true }
      subscriber.on(:this_event) { executed[1] = true }
      
      publisher.publish_event :this_event
      
      executed.all?.should be_true
    end
    
    it 'should not run handlers for other events' do
      executed = false
      subscriber.on(:other_event) { executed = true }
      
      publisher.publish_event :this_event
      
      executed.should be_false
    end
    
    it 'should pass the event data to the event handlers' do
      event_data = nil
      subscriber.on(:this_event) { |data| event_data = data }
      
      publisher.publish_event :this_event, :key1 => 'value1', :key2 => 2
      
      event_data.should be_present
      event_data.key1.should == 'value1'
      event_data.key2.should == 2
    end
    
  end

end