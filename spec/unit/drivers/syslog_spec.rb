require 'unit/drivers/drivers_helper'

# Don't need root privilegies to run in test mode
Eventwire::Drivers::Syslog::DEFAULT_OPTIONS[:publisher_destination_port] = 5514
Eventwire::Drivers::Syslog::DEFAULT_OPTIONS[:subscriber_listen_port] = 5514

describe Eventwire::Drivers::Syslog, :no_content_spec => true do
  include WorkerHelper

  it_should_behave_like 'a driver'

  it "should transfer the content" do
    event_data = nil
    subject.subscribe(:this_event, :this_subscriber) { |data| event_data = data }

    start_worker

    subject.publish :this_event, :content => "wadus"

    eventually {
      sleep_until_no_nil { event_data }
      event_data[:content].should == "wadus"
    }
  end


  it "should contain metada" do
    event_data = nil
    subject.subscribe(:this_event, :this_subscriber) { |data| event_data = data }

    start_worker

    subject.publish :this_event, :content => "wadus"

    eventually {
      sleep_until_no_nil { event_data }
      event_data[:facility].should == 16
      event_data[:severity].should == 5
      event_data[:hostname].should == `hostname`.strip
      event_data[:tag].should == 'this_event'
      event_data[:time].should be_instance_of(Time)
    }
  end



end
