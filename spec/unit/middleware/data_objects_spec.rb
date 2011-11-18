# encoding: UTF-8
require 'spec_helper'

describe Eventwire::Middleware::DataObjects do
  let(:app) { mock }
  subject { Eventwire::Middleware::DataObjects.new(app) }
  
  describe 'subscribe' do
    it 'should call app’s subscribe' do
      app.should_receive(:subscribe).with(:event_name, :handler_id)
      
      subject.subscribe(:event_name, :handler_id)
    end
    
    it 'should make the handler build an event object' do
      app.stub :subscribe do |_, _, handler|
        handler.call(:task_name => 'Cleaning')
        handler.call('task_name' => 'Cleaning')
      end
      
      subject.subscribe :event_name, :handler_id do |data|
        data.task_name.should == 'Cleaning'
      end
    end
    
    it 'should make the handler build an event object without event data' do
      app.stub :subscribe do |_, _, handler|
        handler.call
      end
      
      subject.subscribe :event_name, :handler_id do |data|
        data.task_name.should be_nil
      end
    end
  end
end