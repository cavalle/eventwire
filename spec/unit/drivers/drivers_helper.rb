require 'spec_helper'

shared_examples_for 'a driver' do
  
  before do
    @t = Thread.new { subject.start }
    @t.abort_on_exception = true
  end

  after do
    subject.stop
    @t.join(1)
    @t.kill
  end
  
  it 'should publish to 1 event handler' do
    executed = false
    subject.subscribe(:this_event) { executed = true }
    
    subject.publish :this_event
    
    eventually {
      executed.should be_true
    }
  end
  
  it 'should publish to more than 1 event handler for the event' do
    executed = [false, false]
    subject.subscribe(:this_event, :queue2) { executed[0] = true }
    subject.subscribe(:this_event, :queue1) { executed[1] = true }
    
    subject.publish :this_event
    
    eventually {
      executed.all?.should be_true
    }
  end
  
  it 'should not publish to handlers for other events' do
    executed = false
    subject.subscribe(:other_event) { executed = true }
    
    subject.publish :this_event
    
    eventually {
      executed.should be_false
    }
  end
  
  it 'should pass the event data to the event handlers' do
    event_data = nil
    subject.subscribe(:this_event) { |data| event_data = data }
    
    subject.publish :this_event, 'key1' => 'value1', 'key2' => 2
    
    eventually {
      event_data.should == { 'key1' => 'value1', 'key2' => 2 }
    }
  end
  
end