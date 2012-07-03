# encoding: UTF-8
require 'spec_helper'

describe Eventwire::Middleware::MessagePackSerializer do
  let(:app) { mock }
  subject { Eventwire::Middleware::MessagePackSerializer.new(app) }
  
  describe 'subscribe' do
    it 'should call app’s subscribe' do
      app.should_receive(:subscribe).with(:event_name, :handler_id)
      
      subject.subscribe(:event_name, :handler_id)
    end
    
    it 'should make the handler deserialize event data' do
      app.stub :subscribe do |_, _, &handler|
        handler.call({'task_name' => 'Cleaning'}.to_msgpack)
      end
      
      subject.subscribe :event_name, :handler_id do |data|
        data['task_name'].should == 'Cleaning'
      end
    end
  end
  
  describe 'publish' do
    it 'should call app’s publish serializing data' do
      app.should_receive(:publish).with(:event_name, {'task_name' => 'Cleaning'}.to_msgpack)
      subject.publish(:event_name, {:task_name => 'Cleaning'})
    end
  end
end