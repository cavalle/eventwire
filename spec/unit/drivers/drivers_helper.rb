require 'spec_helper'
require 'timeout'

shared_examples_for 'a driver' do

  after do
    subject.stop
    subject.purge
    if @t
      @t.join(1)
      @t.kill
    end
  end
  
  it 'should publish to 1 event handler' do
    executed = false
    subject.subscribe(:this_event, :this_subscriber) { executed = true }
    
    start_worker
    subject.publish :this_event
    
    eventually {
      executed.should be_true
    }
  end
  
  it 'should publish to more than 1 event handler for the event' do
    executed = [false, false]
    subject.subscribe(:this_event, :queue2) { executed[0] = true }
    subject.subscribe(:this_event, :queue1) { executed[1] = true }
    
    start_worker
    subject.publish :this_event
    
    eventually {
      executed.should == [true, true]
    }
  end
  
  it 'should not publish to handlers for other events' do
    executed = false
    subject.subscribe(:other_event, :this_subscriber) { executed = true }
    
    start_worker
    subject.publish :this_event
    
    eventually {
      executed.should be_false
    }
  end
  
  it 'should pass the event data to the event handlers' do
    event_data = nil
    subject.subscribe(:this_event, :this_subscriber) { |data| event_data = data }
    
    start_worker
    subject.publish :this_event, 'key1' => 'value1', 'key2' => 2
    
    eventually {
      event_data.should == { 'key1' => 'value1', 'key2' => 2 }
    }
  end
  
  def start_worker
    @t = Thread.new { subject.start }
    @t.abort_on_exception = true
    sleep 0.1
  end
  
end

shared_examples_for 'a driver with multiprocess support' do

  before do
    trap('USR1') { @shoutings += 1 }
    @children = []
    @shoutings = 0
    @ppid = Process.pid
  end
  
  def process(&block)
    pid = fork do
      trap('INT') { subject.stop; subject.purge }
      block.call
    end
    @children << pid
    pid
  end
  
  after do
    @children.each {|p| kill_and_wait(p) rescue nil }
  end
  
  def kill_and_wait(pid)
    Process.kill('INT', pid)
    Process.wait(pid)
  end
  
  def shout!
    Process.kill 'USR1', @ppid
  end
  
  example 'one subscriber' do
    process do   
      subject.subscribe(:this_event, :this_subscriber) { shout! }
      subject.start
    end
    
    process do
      subject.publish :this_event
    end
    
    eventually do
      @shoutings.should == 1
    end
  end
  
  example 'several subscribers' do
    process do
      subject.subscribe(:this_event, :first_subscriber) { shout! }
      subject.start
    end
    
    process do
      subject.subscribe(:this_event, :other_subscriber) { shout! }
      subject.start
    end
    
    process do
      subject.publish :this_event
    end
    
    eventually do
      @shoutings.should == 2
    end
  end

  example 'several instances of same subscriber' do
    2.times do
      process do
        subject.subscribe(:this_event, :first_subscriber) { shout! }
        subject.start
      end
    end
    
    process do
      subject.publish :this_event
    end
    
    eventually do
      @shoutings.should == 1
    end
  end
  
end