# encoding: UTF-8
require 'spec_helper'

describe Eventwire::Publisher do
  
  describe '#publish_event' do
    
    before do
      @driver = mock
      Eventwire.configure do |c|
        c.driver = @driver
      end
    end
    
    subject { class_including(Eventwire::Publisher).new }
    
    it 'should publish the event using the current driver' do
      @driver.should_receive(:publish).with(:task_created, anything)
      
      subject.publish_event :task_created
    end
    
    it 'should publish the event with its data using the current driver' do
      @driver.should_receive(:publish).with(:task_created, {:task_name => 'Cleaning'}.to_json)

      subject.publish_event :task_created, :task_name => 'Cleaning'
    end
    
  end
  
end