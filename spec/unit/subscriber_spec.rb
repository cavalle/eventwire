require 'spec_helper'

describe Eventwire::Subscriber do
  
  describe '#on' do
    
    before do
      @driver = mock
      Eventwire.driver = @driver
    end
    
    subject { class_including Eventwire::Subscriber }

    it 'should subscribe to the event using the current driver' do
      Eventwire.driver.should_receive(:subscribe).with(:task_completed, anything)
      
      subject.on(:task_completed) { } 
    end

    it 'should subscribe to the event with incremental handler ids based on the class name' do
      ThisModule = Module.new
      ThisModule::ThisSubscriber = subject
      
      @driver.should_receive(:subscribe).with(:task_completed, 'ThisModule::ThisSubscriber::1')
      @driver.should_receive(:subscribe).with(:task_completed, 'ThisModule::ThisSubscriber::2')
      
      2.times do
        subject.on(:task_completed) { } 
      end
      
      ThisModule.parent.send :remove_const, :ThisModule
    end

    it 'should subscribe to multiple events' do
      Eventwire.driver.should_receive(:subscribe).with(:task_completed, anything)
      Eventwire.driver.should_receive(:subscribe).with(:project_completed, anything)

      subject.on(:task_completed, :project_completed) { }
    end
  end
  
end