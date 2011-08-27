require 'spec_helper'

describe Eventwire::Publisher do
  
  describe '#publish_event' do
    
    subject { class_including(Eventwire::Publisher).new }
    
    it 'should publish the event using the current driver' do
      Eventwire.driver.should_receive(:publish).with(:task_created, nil)
      
      subject.publish_event :task_created
    end
    
    it 'should publish the event with its data using the current driver' do
      Eventwire.driver.should_receive(:publish).with(:task_created, :task_name => 'Cleaning')
      
      subject.publish_event :task_created, :task_name => 'Cleaning'
    end
    
  end
  
end