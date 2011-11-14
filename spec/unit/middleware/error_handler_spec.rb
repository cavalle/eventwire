# encoding: UTF-8
require 'spec_helper'

describe Eventwire::Middleware::ErrorHandler do
  
  let(:app) { mock }
  let(:io) { StringIO.new }
  
  subject { Eventwire::Middleware::ErrorHandler.new(app, :logger => Logger.new(io)) }
  
  describe 'subscribe' do
    it 'should call app’s subscribe' do
      app.should_receive(:subscribe).with(:event_name, :handler_id)
      
      subject.subscribe(:event_name, :handler_id)
    end
    
    it 'should make the handler fault tolerant' do
      app.stub :subscribe do |_, _, handler| 
        handler.call
      end
    
      subject.subscribe :event_name, :handler_id do
        raise 'This exception should be catched'
      end
    end

    context 'when error_handler is present' do
      it 'should make the handler run the block' do
        error = nil

        subject = Eventwire::Middleware::ErrorHandler.new(app,
                                                          :logger => Logger.new(io),
                                                          :error_handler => lambda { |e| error = e })

        app.stub :subscribe do |_, _, handler|
          handler.call
        end

        subject.subscribe :event_name, :handler_id do
          raise 'error!'
        end

        error.message.should == 'error!'
      end
    end
    
    it 'should make the handler log when an exception happens' do
      app.stub :subscribe do |_, _, handler| 
        handler.call
      end
    
      subject.subscribe(:event_name, :handler_id) { raise 'error!' }
      error_backtrace = "#{__FILE__}:#{__LINE__-1}"
      
      io.string.should include('error!')
      io.string.should include(error_backtrace)
    end
  end
  
end