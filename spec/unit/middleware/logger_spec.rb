# encoding: UTF-8
require 'spec_helper'

describe Eventwire::Middleware::Logger do
  let(:app) { mock }
  let(:io) { StringIO.new }
  
  subject { Eventwire::Middleware::Logger.new(app) }
  
  describe 'subscribe' do
    it 'should call app’s subscribe' do
      app.should_receive(:subscribe).with(:event_name, :handler_id)
      
      subject.subscribe(:event_name, :handler_id)
    end
    
    it 'should decorate the handler with logging' do
      Eventwire.logger = Logger.new(io)
      
      app.stub(:subscribe) do |_, _, handler|
        handler.call(:data => 'hey')
      end
      
      subject.subscribe :event_name, :handler_id do
        io.puts "Hello from the handler"
      end
      
      io.string.should == <<-OUTPUT
Starting to process `event_name` with handler `handler_id` and data `{:data=>"hey"}`
Hello from the handler
End processing `event_name`
OUTPUT
    end
    
    it 'should decorate the handler with logging when exceptions happens' do
      Eventwire.logger = Logger.new(io)
      
      app.stub(:subscribe) do |_, _, handler|
        handler.call rescue nil
      end
      
      subject.subscribe :event_name, :handler_id
      
      io.string.should == <<-OUTPUT
Starting to process `event_name` with handler `handler_id` and data `nil`
End processing `event_name`
OUTPUT
    end
    
  end
  
end